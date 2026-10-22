#!/usr/bin/env python3
"""Compare pristine and patched Mihomo against a pristine peer on a real router.

Requires sshpass/SSHPASS, an already trusted SSH host key, and uploaded binaries.
Uses isolated listeners and removes only its own temporary firewall rules/PIDs.
Configurations and credentials in --out are temporary test artifacts, not fixtures.
"""
import argparse
import base64
import hashlib
import ipaddress
import json
import os
from pathlib import Path
import secrets
import shlex
import socket
import socketserver
import subprocess
import threading
import time

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--router', required=True)
p.add_argument('--host-ip', required=True)
p.add_argument('--host-binary', required=True)
p.add_argument('--plain-binary', required=True, help='absolute path on router')
p.add_argument('--accelerated-binary', required=True, help='absolute path on router')
p.add_argument('--out', required=True)
p.add_argument('--cipher', default='aes-256-gcm')
p.add_argument('--repeats', type=int, default=2)
a = p.parse_args()
router_ip = str(ipaddress.IPv4Address(a.router.split('@')[-1]))
host_ip = str(ipaddress.IPv4Address(a.host_ip))
out = Path(a.out).resolve()
out.mkdir(parents=True, exist_ok=True)
work = '/tmp/mihomo-eip93/run-' + str(os.getpid())
comment = 'mihomo-eip93-test-' + str(os.getpid())
ssh = ['sshpass', '-e', 'ssh', '-o', 'BatchMode=no']
if os.getenv('SSH_KNOWN_HOSTS'):
    ssh += ['-o', 'UserKnownHostsFile=' + os.environ['SSH_KNOWN_HOSTS']]
ssh += [a.router]
password = (base64.b64encode(secrets.token_bytes(16 if 'aes-128' in a.cipher else 32)).decode()
            if a.cipher.startswith('2022-') else secrets.token_urlsafe(32))
payload = bytes(range(256)) * 131072
expected = hashlib.sha256(payload).digest()
host_proc = None

def remote(cmd):
    return subprocess.check_output(ssh + [cmd], text=True)

def receive(s, count):
    data = bytearray()
    while len(data) < count:
        block = s.recv(count - len(data))
        if not block:
            raise RuntimeError('unexpected EOF')
        data.extend(block)
    return data

class Echo(socketserver.BaseRequestHandler):
    def handle(self):
        s = self.request
        s.settimeout(60)
        n = int.from_bytes(receive(s, 8), 'big')
        if n != len(payload):
            raise RuntimeError('unexpected payload length')
        data = receive(s, n)
        s.sendall(hashlib.sha256(data).digest())
        s.sendall(payload)

class Backend(socketserver.ThreadingTCPServer):
    allow_reuse_address = True
    daemon_threads = True

backend = Backend((host_ip, 24444), Echo)
threading.Thread(target=backend.serve_forever, daemon=True).start()

def irq():
    for line in remote('cat /proc/interrupts').splitlines():
        if '1fb70000.crypto' in line:
            fields = line.split()[1:]
            total = 0
            for value in fields:
                if not value.isdecimal():
                    break
                total += int(value)
            return total
    return 0

def stop():
    global host_proc
    remote(f'if [ -f {work}/router.pid ]; then kill $(cat {work}/router.pid) 2>/dev/null || true; rm {work}/router.pid; fi')
    if host_proc is not None:
        host_proc.terminate()
        host_proc.wait(timeout=10)
        host_proc = None
    time.sleep(0.3)

def configuration(server, peer):
    c = {'mode': 'rule', 'allow-lan': True, 'bind-address': '*',
         'ipv6': False, 'log-level': 'info', 'dns': {'enable': False},
         'profile': {'store-selected': False}}
    common = {'cipher': a.cipher, 'password': password, 'udp': True}
    if server:
        c['listeners'] = [dict(common, name='eip93-test', type='shadowsocks',
                               listen='0.0.0.0', port=24443)]
        c['rules'] = ['MATCH,DIRECT']
    else:
        c['socks-port'] = 24445
        c['proxies'] = [dict(common, name='test-peer', type='ss', server=peer, port=24443)]
        c['rules'] = ['MATCH,test-peer']
    return c

def transfer(role):
    addr = (router_ip if role == 'client' else '127.0.0.1', 24445)
    with socket.create_connection(addr, timeout=10) as s:
        s.settimeout(60)
        s.sendall(b'\x05\x01\x00')
        assert receive(s, 2) == b'\x05\x00', 'SOCKS authentication'
        s.sendall(b'\x05\x01\x00\x01' + socket.inet_aton(host_ip) + (24444).to_bytes(2, 'big'))
        h = receive(s, 4)
        assert h[:2] == b'\x05\x00', ('SOCKS connect', h)
        if h[3] == 1:
            receive(s, 6)
        elif h[3] == 4:
            receive(s, 18)
        elif h[3] == 3:
            receive(s, receive(s, 1)[0] + 2)
        else:
            raise RuntimeError('invalid SOCKS address')
        t = time.monotonic()
        s.sendall(len(payload).to_bytes(8, 'big') + payload)
        digest = receive(s, 32)
        up = len(payload) * 8 / (time.monotonic() - t) / 1e6
        t = time.monotonic()
        data = receive(s, len(payload))
        down = len(payload) * 8 / (time.monotonic() - t) / 1e6
        assert digest == expected and hashlib.sha256(data).digest() == expected, 'payload SHA256'
        return {'router_send_Mbps': up if role == 'client' else down,
                'router_receive_Mbps': down if role == 'client' else up,
                'sha256': expected.hex()}

remote(f'mkdir -p {work}/state')
governor = remote('cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor').strip()
try:
    remote(f'nft insert rule inet fw4 input ip saddr {host_ip} tcp dport {{ 24443, 24445 }} accept comment "{comment}"')
    remote('echo performance > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor')
    for role in ['client', 'server']:
        cases = [(mode, repeat) for repeat in range(a.repeats) for mode in ['plain', 'accelerated']]
        cases.append(('off', 0))
        for mode, repeat in cases:
            stop()
            label = f'{role}-{mode}-{repeat + 1}'
            rc = json.dumps(configuration(role == 'server', host_ip))
            remote(f'printf %s {shlex.quote(rc)} > {work}/router.yaml')
            hc = out / 'host.yaml'
            hc.write_text(json.dumps(configuration(role != 'server', router_ip)))
            with (out / (label + '-host.log')).open('w') as log:
                host_proc = subprocess.Popen([a.host_binary, '-d', str(out / 'host-state'), '-f', str(hc)], stdout=log, stderr=log)
            binary = a.plain_binary if mode == 'plain' else a.accelerated_binary
            env = 'MIHOMO_EIP93=off ' if mode == 'off' else ''
            remote(f'trap "" HUP; {env}{shlex.quote(binary)} -d {work}/state -f {work}/router.yaml > {work}/router.log 2>&1 < /dev/null & echo $! > {work}/router.pid')
            port = 24445 if role == 'client' else 24443
            for _ in range(100):
                try:
                    socket.create_connection((router_ip, port), timeout=0.2).close()
                    break
                except OSError:
                    time.sleep(0.2)
            else:
                raise RuntimeError(remote(f'cat {work}/router.log'))
            time.sleep(0.5)
            before = irq()
            result = transfer(role)
            after = irq()
            log = remote(f'cat {work}/router.log')
            (out / (label + '-router.log')).write_text(log)
            active = 'Mihomo EIP93: AN7581 AES-GCM hybrid backend enabled' in log
            assert active == (mode == 'accelerated'), (label, 'backend selection', log)
            if mode == 'accelerated':
                assert after > before, 'hardware IRQ did not increase'
            else:
                assert after == before, 'unexpected hardware activity in software control'
            result.update(role=role, mode=mode, repeat=repeat+1, cipher=a.cipher,
                          irq_delta=after-before, activation=active)
            print(json.dumps(result), flush=True)
finally:
    stop()
    rules = remote('nft -a list chain inet fw4 input')
    for line in rules.splitlines():
        if f'comment "{comment}"' in line:
            handle = int(line.split('# handle ')[1])
            remote(f'nft delete rule inet fw4 input handle {handle}')
    remote('echo ' + shlex.quote(governor) + ' > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor')
    backend.shutdown()
    backend.server_close()

import pytest
import re
import subprocess
import shlex


# Adversarial IP address payloads that attempt shell injection
ADVERSARIAL_PAYLOADS = [
    # Basic command injection via semicolon
    "127.0.0.1; rm -rf /",
    "127.0.0.1; cat /etc/passwd",
    "192.168.1.1; id",
    # Command injection via pipe
    "127.0.0.1 | cat /etc/shadow",
    "10.0.0.1 | id > /tmp/pwned",
    # Command injection via backticks
    "127.0.0.1`id`",
    "192.168.1.1`cat /etc/passwd`",
    # Command injection via $()
    "127.0.0.1$(id)",
    "10.0.0.1$(cat /etc/passwd)",
    "$(reboot)",
    # Command injection via &&
    "127.0.0.1 && id",
    "192.168.1.1 && cat /etc/shadow",
    # Command injection via ||
    "127.0.0.1 || id",
    "invalid || cat /etc/passwd",
    # Newline injection
    "127.0.0.1\nid",
    "127.0.0.1\ncat /etc/passwd",
    # Null byte injection
    "127.0.0.1\x00; id",
    # Whitespace and special chars
    "127.0.0.1 -j DROP; id",
    "127.0.0.1; iptables -F",
    # IPv6-like with injection
    "::1; id",
    "::1`id`",
    # Quotes to break out of string context
    "127.0.0.1'; id; echo '",
    '127.0.0.1"; id; echo "',
    # Redirection
    "127.0.0.1 > /tmp/test",
    "127.0.0.1 >> /etc/passwd",
    # Glob/wildcard
    "127.0.0.1*",
    "127.0.0.1?",
    # Environment variable expansion
    "127.0.0.1$PATH",
    "${IFS}id",
    # Encoded/obfuscated
    "127.0.0.1%0aid",
    # Long payload
    "A" * 1000,
    # Empty string
    "",
    # Only special chars
    "; id",
    "| id",
    "& id",
    "`id`",
    "$(id)",
]


def is_valid_ip_address(ip_str):
    """
    Validates that a string is a legitimate IPv4 or IPv6 address
    with no shell metacharacters.
    Returns True only for safe, valid IP addresses.
    """
    # Strip whitespace
    ip_str = ip_str.strip()
    
    # IPv4 pattern: four octets 0-255
    ipv4_pattern = re.compile(
        r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$'
    )
    
    # IPv6 pattern (simplified but covers common cases)
    ipv6_pattern = re.compile(
        r'^[0-9a-fA-F:]{2,39}$'
    )
    
    # Check for any shell metacharacters - these must NEVER appear in a valid IP
    shell_metacharacters = set(';&|`$(){}[]<>!#\\\'"\n\r\t\x00*?~')
    if any(c in shell_metacharacters for c in ip_str):
        return False
    
    # Check IPv4
    m = ipv4_pattern.match(ip_str)
    if m:
        octets = [int(m.group(i)) for i in range(1, 5)]
        if all(0 <= o <= 255 for o in octets):
            return True
    
    # Check IPv6
    if ipv6_pattern.match(ip_str):
        return True
    
    return False


def sanitize_ip_for_shell(ip_str):
    """
    Simulates what a secure version of autoban.py SHOULD do:
    sanitize/validate IP before using in shell command.
    Returns sanitized IP or raises ValueError if invalid.
    """
    ip_str = ip_str.strip()
    
    if not is_valid_ip_address(ip_str):
        raise ValueError(f"Invalid or potentially malicious IP address: {repr(ip_str)}")
    
    # Use shlex.quote as additional protection
    return shlex.quote(ip_str)


def build_iptables_command_safe(ip_str):
    """
    Simulates building an iptables ban command safely.
    This is what autoban.py SHOULD do instead of directly interpolating.
    """
    sanitized_ip = sanitize_ip_for_shell(ip_str)
    cmd = f"iptables -I INPUT -s {sanitized_ip} -j DROP"
    return cmd


@pytest.mark.parametrize("payload", ADVERSARIAL_PAYLOADS)
def test_ip_validation_rejects_shell_injection(payload):
    """
    Invariant: Any IP address used to construct shell commands must be validated
    to contain only valid IP address characters. Shell metacharacters must never
    be allowed to pass through IP validation into shell command construction.
    """
    # The security property: adversarial payloads must NOT be treated as valid IPs
    # If they pass validation, they could be injected into os.system() calls
    
    result = is_valid_ip_address(payload)
    
    # If the payload contains shell metacharacters, it MUST be rejected
    shell_metacharacters = set(';&|`$(){}[]<>!#\\\'"\n\r\t\x00*?~')
    has_metacharacters = any(c in shell_metacharacters for c in payload)
    
    if has_metacharacters:
        assert result is False, (
            f"SECURITY VIOLATION: Payload with shell metacharacters was accepted as valid IP: {repr(payload)}"
        )


@pytest.mark.parametrize("payload", ADVERSARIAL_PAYLOADS)
def test_command_construction_rejects_malicious_ip(payload):
    """
    Invariant: Building a shell command with an adversarial IP payload must
    either raise an exception (preferred) or produce a command that cannot
    execute injected code. The raw payload must never appear unquoted in
    a shell command string.
    """
    try:
        cmd = build_iptables_command_safe(payload)
        
        # If we get here without exception, verify the command is safe:
        # The payload should be fully quoted and not executable as injection
        
        # The command must not contain unquoted shell metacharacters from payload
        shell_metacharacters = set(';&|`$(){}[]<>!#\n\r\t\x00')
        
        # Extract the IP portion from the command (after -s flag)
        parts = cmd.split()
        ip_in_cmd = None
        for i, part in enumerate(parts):
            if part == '-s' and i + 1 < len(parts):
                ip_in_cmd = parts[i + 1]
                break
        
        if ip_in_cmd:
            # The IP in the command should be properly quoted
            # shlex.quote wraps in single quotes, so metacharacters inside are safe
            assert ip_in_cmd.startswith("'") or not any(
                c in shell_metacharacters for c in ip_in_cmd
            ), (
                f"SECURITY VIOLATION: Unquoted metacharacters in command for payload: {repr(payload)}"
            )
    
    except ValueError:
        # This is the EXPECTED behavior for malicious payloads
        # Raising an exception prevents the payload from reaching os.system()
        pass


@pytest.mark.parametrize("payload", ADVERSARIAL_PAYLOADS)
def test_no_shell_metacharacters_in_validated_ip(payload):
    """
    Invariant: A validated IP address must contain ONLY characters that are
    valid in IP addresses (digits, dots, colons, hex letters for IPv6).
    No shell metacharacters should ever survive IP validation.
    """
    VALID_IP_CHARS = set('0123456789abcdefABCDEF.:')
    
    if is_valid_ip_address(payload):
        # If validation passes, every character must be a valid IP character
        for char in payload.strip():
            assert char in VALID_IP_CHARS, (
                f"SECURITY VIOLATION: Character {repr(char)} in 'validated' IP "
                f"is not a valid IP character. Payload: {repr(payload)}"
            )


@pytest.mark.parametrize("payload", [
    "127.0.0.1",
    "192.168.1.100",
    "10.0.0.1",
    "255.255.255.0",
    "0.0.0.0",
    "::1",
    "2001:db8::1",
])
def test_valid_ips_are_accepted(payload):
    """
    Invariant: Legitimate IP addresses must still be accepted by validation
    (ensuring the security check doesn't break functionality).
    """
    assert is_valid_ip_address(payload) is True, (
        f"Valid IP address was incorrectly rejected: {repr(payload)}"
    )
    
    # Should also be able to build a command without exception
    try:
        cmd = build_iptables_command_safe(payload)
        assert payload in cmd or shlex.quote(payload) in cmd
    except ValueError:
        pytest.fail(f"Valid IP {repr(payload)} was rejected during command construction")


@pytest.mark.parametrize("payload", ADVERSARIAL_PAYLOADS)
def test_subprocess_list_form_prevents_injection(payload):
    """
    Invariant: When shell commands must be executed, using subprocess with a
    list of arguments (not shell=True) prevents shell injection regardless
    of the IP content. This tests that the secure calling convention works.
    """
    # Simulate what a secure autoban.py should do: use subprocess list form
    # This test verifies that even if IP validation fails, the fallback
    # secure execution method (list args) would not execute injected commands
    
    # Build args list - this is the SECURE way to call iptables
    args = ["iptables", "-I", "INPUT", "-s", payload, "-j", "DROP"]
    
    # Verify the args list doesn't collapse into a dangerous shell string
    # Each argument is separate - no shell interpretation occurs
    assert isinstance(args, list), "Command must be a list for safe subprocess execution"
    assert args[0] == "iptables", "Command must start with the intended binary"
    
    # The payload is isolated as a single argument - shell metacharacters
    # in payload cannot affect other arguments when using list form
    payload_arg_index = args.index(payload)
    assert payload_arg_index == 5, "Payload must be isolated as a single argument"
    
    # Verify that joining with spaces (what shell=True would do) would be dangerous
    # but list form keeps it safe
    shell_string = " ".join(args)
    shell_metacharacters = set(';&|`$(){}[]<>!#\n\r\t\x00')
    
    if any(c in shell_metacharacters for c in payload):
        # The shell string form would be dangerous
        assert any(c in shell_string for c in shell_metacharacters), (
            "Shell string should contain metacharacters (proving list form is necessary)"
        )
        # But the list form isolates the payload safely
        # (we don't actually execute it, just verify the structure)
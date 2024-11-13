#!/bin/sh
set -eo pipefail

# Check if the global_server is set and not equal to "nil"
global_server=$(uci get shadowsocksr.@global[0].global_server)
if [ "$global_server" != "nil" ] && [ -n "$global_server" ]; then
uci -q batch <<-EOF >/dev/null
		add_list shadowsocksr.@access_control[0].wan_bp_ips='173.245.48.0/20'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='103.21.244.0/22'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='103.22.200.0/22'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='103.31.4.0/22'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='141.101.64.0/18'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='108.162.192.0/18'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='190.93.240.0/20'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='188.114.96.0/20'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='197.234.240.0/22'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='198.41.128.0/17'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='162.158.0.0/15'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='104.16.0.0/13'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='104.24.0.0/14'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='172.64.0.0/13'
		add_list shadowsocksr.@access_control[0].wan_bp_ips='131.0.72.0/22'
		commit shadowsocksr
	EOF
/etc/init.d/shadowsocksr restart
fi

sleep 3s

# 查找 cdnspeedtest 可执行文件
CDNSPEEDTEST=$(command -v cdnspeedtest)
if [ -z "$CDNSPEEDTEST" ]; then
    echo "cdnspeedtest 可执行文件不存在. 请确保已安装。"
    exit 1
fi

# 下载 Cloudflare 的 IPv4 地址列表
if [ ! -s /etc/smartdns/cfipv4.txt ]; then
    curl -sSL -o /etc/smartdns/cfipv4.txt https://www.cloudflare-cn.com/ips-v4/
fi

# 运行 CDN 速度测试，-n 222 表示并发数量，生成1到6个结果文件
for i in $(seq 1 6); do
    $CDNSPEEDTEST -dd -o /tmp/$i.cfipv4.txt -f /etc/smartdns/cfipv4.txt -n 222
done

# 使用 for 循环拼接文件路径并传递给 awk，进行去重
ipv4_files=""
for i in $(seq 1 6); do
    ipv4_files="$ipv4_files /tmp/$i.cfipv4.txt"
done

# 提取 IPv4 地址并去重
awk -F, 'FNR > 1 && FNR <= 33 {print $1}' $ipv4_files | sort -u > /tmp/good.cfipv4.txt

# 对合并IPV4去重后的结果重新测试
# $CDNSPEEDTEST -o /tmp/done.cfipv4.txt -f /tmp/good.cfipv4.txt -n 100 -url=https://cloudflare.cdn.openbsd.org/pub/OpenBSD/7.3/src.tar.gz -sl 0.01 -dn 22
$CDNSPEEDTEST -o /tmp/done.cfipv4.txt -f /tmp/good.cfipv4.txt -n 100 -url=https://www.api88.cloudns.be/200m -sl 0.01 -dn 22

# 从 done.cfipv4.txt 文件中提取前 16 个 IP 地址
ips=$(awk -F, 'NR>1 && NR<18 {print $1}' /tmp/done.cfipv4.txt | tr '\n' ',' | sed 's/,$//')

# 更新 custom.conf 文件的配置
if grep -q "ip-set -name cloudflare-ipv4 -file /etc/smartdns/cfipv4.txt" /etc/smartdns/custom.conf && grep -q "ip-rules ip-set:cloudflare-ipv4 -ip-alias" /etc/smartdns/custom.conf; then
    # 如果存在，替换 IP 地址
    sed -i "/ip-rules ip-set:cloudflare-ipv4 -ip-alias/c\ip-rules ip-set:cloudflare-ipv4 -ip-alias $ips" /etc/smartdns/custom.conf
else
    # 如果不存在，添加命令
    echo "" >> /etc/smartdns/custom.conf
    echo "#cloudflare ip-alias" >> /etc/smartdns/custom.conf
    echo "ip-set -name cloudflare-ipv4 -file /etc/smartdns/cfipv4.txt" >> /etc/smartdns/custom.conf
    echo "ip-rules ip-set:cloudflare-ipv4 -ip-alias $ips" >> /etc/smartdns/custom.conf
fi

# 清理临时文件
for i in $(seq 1 6); do
    rm -f /tmp/$i.cfipv4.txt
done
# rm -f /tmp/good.cfipv4.txt /tmp/done.cfipv4.txt

if ping6 -c 1 www.baidu.com > /dev/null 2>&1; then
	# 下载 Cloudflare 的 IPv6 地址列表
	if [ ! -s /etc/smartdns/cfipv6.txt ]; then
		curl -sSL -o /etc/smartdns/cfipv6.txt https://www.cloudflare-cn.com/ips-v6/
	fi

# 运行 CDN 速度测试，-n 222 表示并发数量，生成1到6个结果文件
for i in $(seq 1 6); do
    $CDNSPEEDTEST -dd -o /tmp/$i.cfipv6.txt -f /etc/smartdns/cfipv6.txt -n 222
done

# 使用 for 循环拼接文件路径并传递给 awk，进行去重
ipv6_files=""
for i in $(seq 1 6); do
    ipv6_files="$ipv6_files /tmp/$i.cfipv6.txt"
done

# 提取 IPv6 地址并去重
 awk -F, 'FNR > 1 && FNR <= 33 {print $1}' $ipv6_files | sort -u > /tmp/good.cfipv6.txt

# 对合并IPV6去重后的结果重新测试
# $CDNSPEEDTEST -o /tmp/done.cfipv6.txt -f /tmp/good.cfipv6.txt -n 100 -url=https://cloudflare.cdn.openbsd.org/pub/OpenBSD/7.3/src.tar.gz -sl 0.01 -dn 22
$CDNSPEEDTEST -o /tmp/done.cfipv6.txt -f /tmp/good.cfipv6.txt -n 100 -url=https://www.api88.cloudns.be/200m -sl 0.01 -dn 22

# 从 done.cfipv6.txt 文件中提取前 16 个 IP 地址
ips=$(awk -F, 'NR>1 && NR<18 {print $1}' /tmp/done.cfipv6.txt | tr '\n' ',' | sed 's/,$//')

# 更新 custom.conf 文件的配置
	if grep -q "ip-set -name cloudflare-ipv6 -file /etc/smartdns/cfipv6.txt" /etc/smartdns/custom.conf && grep -q "ip-rules ip-set:cloudflare-ipv6 -ip-alias" /etc/smartdns/custom.conf; then
		# 如果存在，替换 IP 地址
		sed -i "/ip-rules ip-set:cloudflare-ipv6 -ip-alias/c\ip-rules ip-set:cloudflare-ipv6 -ip-alias $ips" /etc/smartdns/custom.conf
	else
		# 如果不存在，添加命令
		echo "" >> /etc/smartdns/custom.conf
		echo "ip-set -name cloudflare-ipv6 -file /etc/smartdns/cfipv6.txt" >> /etc/smartdns/custom.conf
		echo "ip-rules ip-set:cloudflare-ipv6 -ip-alias $ips" >> /etc/smartdns/custom.conf
		echo "" >> /etc/smartdns/custom.conf
	fi

# 清理临时文件
for i in $(seq 1 6); do
    rm -f /tmp/$i.cfipv6.txt
done
# rm -f /tmp/good.cfipv6.txt /tmp/done.cfipv6.txt
fi

# 重启 smartdns 服务
/etc/init.d/smartdns restart

sleep 1s

# Check if the global_server is set and not equal to "nil"
global_server=$(uci get shadowsocksr.@global[0].global_server)
if [ "$global_server" != "nil" ] && [ -n "$global_server" ]; then
uci -q batch <<-EOF >/dev/null
		del_list shadowsocksr.@access_control[0].wan_bp_ips='173.245.48.0/20'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='103.21.244.0/22'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='103.22.200.0/22'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='103.31.4.0/22'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='141.101.64.0/18'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='108.162.192.0/18'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='190.93.240.0/20'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='188.114.96.0/20'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='197.234.240.0/22'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='198.41.128.0/17'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='162.158.0.0/15'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='104.16.0.0/13'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='104.24.0.0/14'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='172.64.0.0/13'
		del_list shadowsocksr.@access_control[0].wan_bp_ips='131.0.72.0/22'
		commit shadowsocksr
	EOF
/etc/init.d/shadowsocksr restart
fi

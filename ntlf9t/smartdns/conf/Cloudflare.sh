#!/bin/sh

# 下载Cloudflare的IP地址列表
wget -O /usr/cfipv4.txt https://www.cloudflare-cn.com/ips-v4/#
wget -O /usr/cfipv6.txt https://www.cloudflare-cn.com/ips-v6/#

# 运行CDN速度测试，下载测速地址建议换你自己搭建的，222线程根据自己路由器性能调整
/usr/cdnspeedtest -url https://cf-speedtest.acfun.win/200mb.test -o /usr/good.cfipv4.txt -f /usr/cfipv4.txt -dn 15 -dt 10 -n 222
/usr/cdnspeedtest -url https://cf-speedtest.acfun.win/200mb.test -o /usr/good.cfipv6.txt -f /usr/cfipv6.txt -dn 15 -dt 10 -n 222

# 从good.cfipv4.txt文件中提取前5个IP地址
ips=$(awk -F, 'NR>1 && NR<7 {print $1}' /usr/good.cfipv4.txt | tr '\n' ',' | sed 's/,$//')

# 检查custom.conf文件中是否存在这两行命令
if grep -q "ip-set -name cloudflare-ipv4 -file /usr/cfipv4.txt" /etc/smartdns/custom.conf && grep -q "ip-rules ip-set:cloudflare-ipv4 -ip-alias" /etc/smartdns/custom.conf; then
    # 如果存在，替换IP地址
    sed -i "/ip-rules ip-set:cloudflare-ipv4 -ip-alias/c\ip-rules ip-set:cloudflare-ipv4 -ip-alias $ips" /etc/smartdns/custom.conf
else
    # 如果不存在，添加这两行命令
    echo "ip-set -name cloudflare-ipv4 -file /usr/cfipv4.txt" >> /etc/smartdns/custom.conf
    echo "ip-rules ip-set:cloudflare-ipv4 -ip-alias $ips" >> /etc/smartdns/custom.conf
fi

# 从good.cfipv6.txt文件中提取前5个IP地址
ips=$(awk -F, 'NR>1 && NR<7 {print $1}' /usr/good.cfipv6.txt | tr '\n' ',' | sed 's/,$//')

# 检查custom.conf文件中是否存在这两行命令
if grep -q "ip-set -name cloudflare-ipv6 -file /usr/cfipv6.txt" /etc/smartdns/custom.conf && grep -q "ip-rules ip-set:cloudflare-ipv6 -ip-alias" /etc/smartdns/custom.conf; then
    # 如果存在，替换IP地址
    sed -i "/ip-rules ip-set:cloudflare-ipv6 -ip-alias/c\ip-rules ip-set:cloudflare-ipv6 -ip-alias $ips" /etc/smartdns/custom.conf
else
    # 如果不存在，添加这两行命令
    echo "ip-set -name cloudflare-ipv6 -file /usr/cfipv6.txt" >> /etc/smartdns/custom.conf
    echo "ip-rules ip-set:cloudflare-ipv6 -ip-alias $ips" >> /etc/smartdns/custom.conf
fi

# 重启smartdns
/etc/init.d/smartdns restart

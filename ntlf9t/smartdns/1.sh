#!/bin/sh
#set -eo pipefail

# 查找 cdnspeedtest 可执行文件
CDNSPEEDTEST=$(command -v cdnspeedtest)
if [ -z "$CDNSPEEDTEST" ]; then
    echo "cdnspeedtest executable not found. Please ensure it is installed."
    exit 1
fi

# 下载 Cloudflare 的 IPv4 和 IPv6 地址列表
wget -O /etc/smartdns/cfipv4.txt https://www.cloudflare-cn.com/ips-v4/
# wget -O /etc/smartdns/cfipv6.txt https://www.cloudflare-cn.com/ips-v6/

# 运行 CDN 速度测试，-n 222 表示并发数量，生成1到6个结果文件
for i in $(seq 1 6); do
    $CDNSPEEDTEST -dd -o /tmp/$i.cfipv4.txt -f /etc/smartdns/cfipv4.txt -n 222
    # $CDNSPEEDTEST -dd -o /tmp/$i.cfipv6.txt -f /etc/smartdns/cfipv6.txt -n 222
done

# 合并去重测试结果
awk -F, 'FNR > 1 && FNR <= 33 {print $1}' /tmp/{1..6}.cfipv4.txt | sort -u > /tmp/good.cfipv4.txt

# 对合并去重后的结果重新测试
$CDNSPEEDTEST -o /tmp/done.cfipv4.txt -f /tmp/good.cfipv4.txt -n 100 -url=https://cloudflare.cdn.openbsd.org/pub/OpenBSD/7.3/src.tar.gz -sl 0.01 -dn 22
# $CDNSPEEDTEST -o /tmp/done.cfipv6.txt -f /tmp/good.cfipv6.txt -n 100 -url=https://cloudflare.cdn.openbsd.org/pub/OpenBSD/7.3/src.tar.gz -sl 0.01 -dn 22

# 提取前16个IP地址并更新 custom.conf 文件
ips=$(awk -F, 'NR>1 && NR<18 {print $1}' /tmp/done.cfipv4.txt | tr '\n' ',' | sed 's/,$//')

# 更新 custom.conf 文件的配置
if grep -q "ip-set -name cloudflare-ipv4 -file /etc/smartdns/cfipv4.txt" /etc/smartdns/custom.conf && grep -q "ip-rules ip-set:cloudflare-ipv4 -ip-alias" /etc/smartdns/custom.conf; then
    sed -i "/ip-rules ip-set:cloudflare-ipv4 -ip-alias/c\ip-rules ip-set:cloudflare-ipv4 -ip-alias $ips" /home/lin/bf-package-master/ntlf9t/smartdns
else
    echo "" >> /home/lin/bf-package-master/ntlf9t/smartdns
    echo "#cloudflare ip-alias" >> /home/lin/bf-package-master/ntlf9t/smartdns
    echo "ip-set -name cloudflare-ipv4 -file /etc/smartdns/cfipv4.txt" >> /home/lin/bf-package-master/ntlf9t/smartdns
    echo "ip-rules ip-set:cloudflare-ipv4 -ip-alias $ips" >> /home/lin/bf-package-master/ntlf9t/smartdns
fi

# 清理临时文件
cd /tmp/
rm -f {1..6}.cfipv4.txt good.cfipv4.txt done.cfipv4.txt
# rm -f {1..6}.cfipv6.txt good.cfipv6.txt done.cfipv6.txt

# 重启 smartdns 服务
#/etc/init.d/smartdns restart


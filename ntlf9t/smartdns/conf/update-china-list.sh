#/bin/sh

mkdir -p /tmp/smartdns/


wget -O /tmp/smartdns/china.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf
wget -O /tmp/smartdns/apple.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf
wget -O /tmp/smartdns/google.conf https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf

#合并
cat /tmp/smartdns/apple.conf >> /tmp/smartdns/china.conf 2>/dev/null
cat /tmp/smartdns/google.conf >> /tmp/smartdns/china.conf 2>/dev/null

#删除不符合规则的域名
sed -i "s/^server=\/\(.*\)\/[^\/]*$/nameserver \/\1\/china/g;/^nameserver/!d" /tmp/smartdns/china.conf 2>/dev/null

mv -f /tmp/smartdns/china.conf  /etc/smartdns/smartdns-domains.china.conf
rm -rf /tmp/smartdns/

/etc/init.d/smartdns reload

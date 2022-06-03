#!/bin/sh
[ -f "$1" ] && china_ip=$1
ipset -! flush china 2>/dev/null
ipset list china > /dev/null || ipset create china hash:net
ipset -! -R <<-EOF || exit 1
	$(cat ${china_ip:=/etc/ssrplus/china_ssr.txt} | sed -e "s/^/add china /")
EOF

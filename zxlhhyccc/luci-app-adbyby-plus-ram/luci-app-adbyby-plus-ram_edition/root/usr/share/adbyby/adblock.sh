#!/bin/sh
	# 防止重复启动
	for pid in $(ps -w | grep "${0##*/}" | grep -v grep | awk '{print $1}' &); do
		[ "$pid" != "$$" ] && exit 1
	done

	if ! mount | grep adbyby >/dev/null 2>&1;then
		echo "Adbyby is not mounted,Stop update!"
		exit 1
	fi

	if [ "$(uci -q get adbyby.@adbyby[0].wan_mode)" == "1" ];then
		rm -f /tmp/dnsmasq.adblock
		wget --no-hsts -O- https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/easylistchina%2Beasylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/dnsmasq.adblock || \
		wget --no-hsts -O- https://easylist-downloads.adblockplus.org/easylistchina+easylist.txt | grep ^\|\|[^\*]*\^$ | sed -e 's:||:address\=\/:' -e 's:\^:/0\.0\.0\.0:' > /tmp/dnsmasq.adblock
		if [ -s "/tmp/dnsmasq.adblock" ];then
			sed -i '/youku.com/d' /tmp/dnsmasq.adblock
			if ( ! cmp -s /tmp/dnsmasq.adblock /tmp/adbyby/adbyby_adblock/dnsmasq.adblock );then
				cp -f /tmp/dnsmasq.adblock /tmp/adbyby/adbyby_adblock/dnsmasq.adblock
				/usr/share/adbyby/adupdate.sh restartdnsmasq
			else
				/usr/share/adbyby/adupdate.sh
			fi
			rm -f /tmp/dnsmasq.adblock
		fi
	else
		/usr/share/adbyby/adupdate.sh
	fi

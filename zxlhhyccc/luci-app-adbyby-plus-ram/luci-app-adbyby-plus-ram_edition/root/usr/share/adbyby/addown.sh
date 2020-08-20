#!/bin/sh
	[ "$1" != "--down" ] && exit 1
	# 防止重复启动
	[ -f /var/lock/adbyby.lock ] && exit 1
	touch /var/lock/adbyby.lock

	if ! mount | grep adbyby >/dev/null 2>&1;then
		/etc/init.d/adbyby start &
		exit 1
	fi

	if [ "$(head -1 /usr/share/adbyby/data/lazy.txt | awk -F' ' '{print $3,$4}')" == "2017-1-2 00:12:25" ];then
		while : ; do
			wget --no-hsts -T 3 -O /tmp/lazy.txt https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules/lazy.txt
			if [ "$?" == "0" ];then
				cp -f /tmp/lazy.txt /usr/share/adbyby/data/lazy.txt
				rm -f /tmp/lazy.txt
				break
			else
				sleep 2
			fi
		done
		while : ; do
			wget --no-hsts -T 3 -O /tmp/video.txt https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules/video.txt
			if [ "$?" == "0" ];then
				cp -f /tmp/video.txt /usr/share/adbyby/data/video.txt
				rm -f /tmp/video.txt
				break
			else
				sleep 2
			fi
		done
	fi

	if [ "$(uci -q get adbyby.@adbyby[0].wan_mode)" == "1" ];then
		mkdir -p /tmp/adbyby/adbyby_adblock
		while : ; do
			wget --no-hsts -T 3 -O /tmp/adbyby/adbyby_adblock/dnsmasq.adblock https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/dnsmasq.adblock
			[ "$?" == "0" ] && break || sleep 2
		done

		while : ; do
			wget --no-hsts -T 3 -O /tmp/adbyby/adbyby_adblock/md5 https://small_5.coding.net/p/adbyby/d/adbyby/git/raw/master/md5_1
			[ "$?" == "0" ] && break || sleep 2
		done

		md5_local=$(md5sum /tmp/adbyby/adbyby_adblock/dnsmasq.adblock | awk -F' ' '{print $1}')
		md5_online=$(sed 's/":"/\n/g' /tmp/adbyby/adbyby_adblock/md5 | sed 's/","/\n/g' | sed -n '2P')
		rm -f /tmp/adbyby/adbyby_adblock/md5
		[ "$md5_local"x != "$md5_online"x ] && rm -rf /tmp/adbyby/adbyby_adblock
	fi

	rm -f /var/lock/adbyby.lock
	/etc/init.d/adbyby start &

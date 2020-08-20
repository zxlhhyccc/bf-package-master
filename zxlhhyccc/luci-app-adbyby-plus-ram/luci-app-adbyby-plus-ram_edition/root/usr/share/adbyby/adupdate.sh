#!/bin/sh
A=$1
B=0
	# 防止重复启动
	for pid in $(ps -w | grep "${0##*/}" | grep -v grep | awk '{print $1}' &); do
		[ "$pid" != "$$" ] && exit 1
	done

	if ! mount | grep adbyby >/dev/null 2>&1;then
		echo "Adbyby is not mounted,Stop update!"
		exit 1
	fi

	md5sum /usr/share/adbyby/data/lazy.txt /usr/share/adbyby/data/video.txt > /tmp/local-md5.json
	wget --no-hsts -O /tmp/md5.json https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules/md5.json || wget --no-hsts -O /tmp/md5.json https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/md5.json
	if [ -s "/tmp/md5.json" ];then
		lazy_local=$(grep 'lazy' /tmp/local-md5.json | awk -F' ' '{print $1}')
		video_local=$(grep 'video' /tmp/local-md5.json | awk -F' ' '{print $1}')  
		lazy_online=$(sed  's/":"/\n/g' /tmp/md5.json  |  sed  's/","/\n/g' | sed -n '2p')
		video_online=$(sed  's/":"/\n/g' /tmp/md5.json  |  sed  's/","/\n/g' | sed -n '4p')
		if [ "$lazy_online"x != "$lazy_local"x ];then
			rm -f /usr/share/adbyby/data/*.bak /tmp/lazy.txt
			wget --no-hsts -O /tmp/lazy.txt https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules/lazy.txt || wget --no-hsts -O /tmp/lazy.txt https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/lazy.txt
			cp -f /tmp/lazy.txt /usr/share/adbyby/data/lazy.txt
			rm -f /tmp/lazy.txt
			echo $(date +"%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
			B=1
		fi
		if [ "$video_online"x != "$video_local"x ];then
			rm -f /usr/share/adbyby/data/*.bak /tmp/video.txt
			wget --no-hsts -O /tmp/video.txt https://cdn.jsdelivr.net/gh/adbyby/xwhyc-rules/video.txt || wget --no-hsts -O /tmp/video.txt https://raw.githubusercontent.com/adbyby/xwhyc-rules/master/video.txt
			cp -f /tmp/video.txt /usr/share/adbyby/data/video.txt
			rm -f /tmp/video.txt
			echo $(date +"%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
			B=1
		fi
	fi
	rm -f /tmp/local-md5.json /tmp/md5.json

	if [ "$A" == "restartdnsmasq" ] && [ $B == 1 ];then
		echo "Adbyby rules and Adblock rules need update!"
		/etc/init.d/adbyby restart
	elif [ "$A" == "restartdnsmasq" ] && [ $B != 1 ];then
		echo "Adbyby rules no change!"
		echo "Adblock rules need update!"
		cp -f /tmp/adbyby/adbyby_adblock/dnsmasq.adblock /var/etc/dnsmasq-adbyby.d/04-dnsmasq.adblock
		echo "Restart Dnsmasq"
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		echo $(date +"%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
	elif [ "$A" != "restartdnsmasq" ] && [ $B == 1 ];then
		echo "Adbyby rules need update!"
		echo "Adblock rules no change!"
		killall -q -9 adbyby
		/usr/share/adbyby/adbyby &>/dev/null &
	else
		echo "All rules no change!"
		echo $(date +"%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
	fi

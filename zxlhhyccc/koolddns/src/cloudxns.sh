#!/bin/sh

timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
DATE=$(date)

accesskey=$1
signature=$2
domain=$3
name=$4
ip=$5

version=$(cat /etc/openwrt_release 2>/dev/null | grep -w DISTRIB_RELEASE | grep -w "By stones")
version2=$(cat /etc/openwrt_release 2>/dev/null | grep -w DISTRIB_DESCRIPTION | grep -w Koolshare)
[ -z "$version" -a -z "$version2" ] && exit 0

enabled=$(uci -q get koolddns.@global[0].enabled)
[ -z "$enabled" ] && enabled=0
[ "$enabled" -eq 0 ] || [ -z "$accesskey" ] || [ -z "$signature" ] || [ -z "$domain" ] || [ -z "$name" ] || [ -z "$ip" ] && exit

subname=$(echo "$name" | awk -F'.' '{print $1}')
subdomain=$(echo "$name" | awk -F'.' '{print $2}')
if [ "Z$subdomain" == "Z" ]; then
	#add support sencond subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		cloudxnsdomain=$domain
	elif [ "Z$subname" == "Z*" ]; then
		cloudxnsdomain=$name.$domain
	else
		cloudxnsdomain=$name.$domain
	fi
else
	#add support third subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		cloudxnsdomain=$subdomain.$domain
	elif [ "Z$subname" == "Z*" ]; then
		cloudxnsdomain=$name.$domain
	else
		cloudxnsdomain=$name.$domain
	fi
fi


remoteresolve2ip() {
	#remoteresolve2ip cloudxnsdomain<string>
	cloudxnsdomain=$1
	tmp_ip=`drill @lv3ns1.ffdns.net $cloudxnsdomain 2>/dev/null |grep 'IN'|awk '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`drill @lv3ns2.ffdns.net $cloudxnsdomain 2>/dev/null |grep 'IN'|awk '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`dig @114.114.115.115 $cloudxnsdomain 2>/dev/null |grep 'IN'|awk '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	echo -n $tmp_ip
}

resolve2ip() {
	#resolve2ip cloudxnsdomain<string>
	cloudxnsdomain=$1
	localtmp_ip=`nslookup $cloudxnsdomain lv3ns1.ffdns.net 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk '{print $1}'|tail -1`
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $cloudxnsdomain 223.5.5.5 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk '{print $1}'|tail -1`
	fi
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $cloudxnsdomain 114.114.115.115 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk '{print $1}'|tail -1`
	fi
	echo -n $localtmp_ip
}

get_domainid() {
    # Get domain ID
	URL_D="https://www.cloudxns.net/api2/domain"
	HMAC_D=$(echo -n "$accesskey$URL_D$DATE$signature"|md5sum|cut -d" " -f1)
	domainID=$(curl -k -s "$URL_D" -H "API-KEY: $accesskey" -H "API-REQUEST-DATE: $DATE" -H "API-HMAC: $HMAC_D"|grep -o "id\":\"[0-9]*\",\"domain\":\"$domain"|grep -o "[0-9]*"|head -n1)
}

get_recordid() {
	local recordID
	get_domainid
    # Get Record ID
	URL_R="https://www.cloudxns.net/api2/record/$domainID?host_id=0&row_num=500"
	HMAC_R=$(echo -n "$accesskey$URL_R$DATE$signature"|md5sum|cut -d" " -f1)
	recordID=$(curl -k -s "$URL_R" -H "API-KEY: $accesskey" -H "API-REQUEST-DATE: $DATE" -H "API-HMAC: $HMAC_R"|grep -o "record_id\":\"[0-9]*\",\"host_id\":\"[0-9]*\",\"host\":\"$name\""|grep -o "record_id\":\"[0-9]*"|grep -o "[0-9]*")
	echo -n $recordID
	
}

add_record() {
	local recordRS
	get_domainid
	# added record
	URL_AR="https://www.cloudxns.net/api2/record"
	JSON_A="{\"domain_id\": $domainID,\"host\":\"$name\",\"value\":\"$ip\",\"type\":\"A\",\"line_id\":1}"
	HMAC_AR=$(echo -n "$accesskey$URL_AR$JSON_A$DATE$signature"|md5sum|cut -d" " -f1)
	recordRS=$(curl -k -s "$URL_AR" -X POST -d "$JSON_A" -H "API-KEY: $accesskey" -H "API-REQUEST-DATE: $DATE" -H "API-HMAC: $HMAC_AR" -H 'Content-Type: application/json')
	echo -n $recordRS
}

update_record() {
	local recordRS
	get_domainid
    # Update IP
	URL_UR="https://www.cloudxns.net/api2/record/$1"
	JSON_U="{\"domain_id\": $domainID,\"host\":\"$name\",\"value\":\"$ip\"}"
	HMAC_UR=$(echo -n "$accesskey$URL_UR$JSON_U$DATE$signature"|md5sum|cut -d" " -f1)
	recordRS=$(curl -k -s "$URL_UR" -X PUT -d "$JSON_U" -H "API-KEY: $accesskey" -H "API-REQUEST-DATE: $DATE" -H "API-HMAC: $HMAC_UR" -H 'Content-Type: application/json')
	echo -n $recordRS
}

check_cloudxns() {
	current_ip=$(resolve2ip $cloudxnsdomain)
	remotecurrent_ip=$(remoteresolve2ip $cloudxnsdomain)
	
	echo $(date): "本地接口IP :" ${ip}
	if [ "Z$remotecurrent_ip" == "Z" ]; then
		echo $(date): "远程解析IP : 暂无解析记录！"
		recordID='' # NO Remote Resolve IP Means new Record_ID
	else
		if [ "Z$current_ip" == "Z" ]; then
			echo $(date): "本地解析IP : 本地解析尚未生效！"
			echo $(date): "远程解析IP :" ${remotecurrent_ip}
		else
			if [ "Z$current_ip" != "Z$remotecurrent_ip" ]; then
				echo $(date): "本地解析IP : 本地解析尚未生效！"
				echo $(date): "远程解析IP :" ${remotecurrent_ip}
			else
				echo $(date): "本地解析IP :" ${current_ip}
				echo $(date): "远程解析IP :" ${remotecurrent_ip}
			fi
		fi
	fi
	if [ "Z$ip" == "Z$remotecurrent_ip" ]; then
		echo $(date): "解析地址一致，无需更新"
		return 0
	else
		echo $(date): "正在检查CloudXns解析配置..."
		return 1
	fi
}

do_ddns_record() {
	if [ "Z$recordID" == "Z" ]; then
		recordID=`get_recordid`
	fi
	if [ "Z$recordID" == "Z" ]; then
		echo $(date): "添加记录..."
		recordRS=`add_record`
		recordID=`get_recordid`
		doaction=1
	else
		echo $(date): "更新记录..."
		recordRS=`update_record $recordID`
		doaction=0
	fi
	
	recordCD=$(echo $recordRS | awk -F',' '{print $1}'  | awk -F':' '{print $2}')
    if [ "$recordCD" = "1" ]; then
		if [ "$doaction" == 1 ]; then
			echo $(date): "koolddns添加成功!"
		else
			echo $(date): "koolddns更新成功!"
		fi
        return 0
    else
        echo $(date): "更新失败，请检查配置文件！"
		# Echo error message
		echo $(date): "错误信息: " `echo $recordRS | awk -F',' '{print $2}'  | awk -F':' '{print $2}'`
        return 1
    fi
}


[ -x /usr/bin/openssl -a -x /usr/bin/curl -a -x /bin/sed ] ||
	( echo $(date): "Need openssl +bind-dig +curl + sed !" && exit 1 )

check_cloudxns || do_ddns_record
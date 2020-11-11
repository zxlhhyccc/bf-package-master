#!/bin/sh

timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")
oncekey=$(/usr/bin/date "+%s%N")

accesskey=$1
signature=$2
domain=$3
name=$4
ip=$5
alinum=$6
record_type=$7
ttl_time=$8
recordid=$9

version=$(cat /etc/openwrt_release 2>/dev/null | grep -w DISTRIB_RELEASE | grep -w "By stones")
version2=$(cat /etc/openwrt_release 2>/dev/null | grep -w DISTRIB_DESCRIPTION | grep -w Koolshare)
[ -z "$version" -a -z "$version2" ] && exit 0

enabled=$(uci -q get koolddns.@global[0].enabled)
[ -z "$enabled" ] && enabled=0
[ "$enabled" -eq 0 ] || [ -z "$accesskey" ] || [ -z "$signature" ] || [ -z "$domain" ] || [ -z "$name" ] || [ -z "$ip" ] && exit

[ -z "$record_type" ] && record_type="A"
[ -z "$ttl_time" ] && ttl_time=600

subname=$(echo "$name" | awk -F'.' '{print $1}')
subdomain=$(echo "$name" | awk -F'.' '{print $2}')
if [ "Z$subdomain" == "Z" ]; then
	#add support sencond subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		alidomain=$domain
		url_name=%40
	elif [ "Z$subname" == "Z*" ]; then
		alidomain=$name.$domain
		url_name=%2A
	else
		alidomain=$name.$domain
		url_name=$name
	fi
else
	#add support third subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		alidomain=$subdomain.$domain
		url_name=%40.$subdomain
	elif [ "Z$subname" == "Z*" ]; then
		alidomain=$name.$domain
		url_name=%2A.$subdomain
	else
		alidomain=$name.$domain
		url_name=$name
	fi
fi

remoteresolve2ip() {
	#remoteresolve2ip alidomain<string>
	alidomain=$1
	tmp_ip=`drill @ns1.alidns.com $alidomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`drill @ns2.alidns.com $alidomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`dig @223.5.5.5 $alidomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	echo -n $tmp_ip
}

resolve2ip() {
	#resolve2ip alidomain<string>
	alidomain=$1
	localtmp_ip=`nslookup $alidomain 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p' | awk -F' ' '{print $1}'`
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $alidomain ns2.alidns.com 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p' | awk '{print $1}'|tail -1`
	fi
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $alidomain 223.5.5.5 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk '{print $1}'|tail -1`
	fi
	echo -n $localtmp_ip
}

urlencode() {
	# urlencode url<string>
	out=''
	for c in $(echo -n $1 | sed 's/[^\n]/&\n/g'); do
		case $c in
			[a-zA-Z0-9._-]) out="$out$c" ;;
			*) out="$out$(printf '%%%02X' "'$c")" ;;
		esac
	done
	echo -n $out
}

send_request() {
	# send_request action<string> args<string>
	local args="AccessKeyId=$accesskey&Action=$1&Format=json&$2&Version=2015-01-09"
	local hash=$(urlencode $(echo -n "GET&%2F&$(urlencode $args)" | openssl dgst -sha1 -hmac "$signature&" -binary | openssl base64))
	curl -sSL "http://alidns.aliyuncs.com/?$args&Signature=$hash"
}

get_recordid() {
	#sed -n 's/.*RecordId[^0-9]*\([0-9]*\).*/\1/p'
	jsonfilter -e '@.DomainRecords.Record[*].RecordId'
}

get_response_recordid() {
	#sed -n 's/.*RecordId[^0-9]*\([0-9]*\).*/\1/p'
	jsonfilter -e '@.RecordId'
}

get_response_message() {
	jsonfilter -e '@.Message'
}

query_recordid() {
	send_request "DescribeSubDomainRecords" "SignatureMethod=HMAC-SHA1&SignatureNonce=$oncekey&SignatureVersion=1.0&SubDomain=$url_name.$domain&Timestamp=$timestamp"
}

get_recordinfo() {
	send_request "DescribeDomainRecordInfo" "SignatureMethod=HMAC-SHA1&SignatureNonce=$oncekey&SignatureVersion=1.0&RecordId=$1&Timestamp=$timestamp"
}

update_record() {
	send_request "UpdateDomainRecord" "RR=$url_name&RecordId=$1&SignatureMethod=HMAC-SHA1&SignatureNonce=$oncekey&SignatureVersion=1.0&TTL=$ttl_time&Timestamp=$timestamp&Type=$record_type&Value=$ip"
}

add_record() {
	send_request "AddDomainRecord&DomainName=$domain" "RR=$url_name&SignatureMethod=HMAC-SHA1&SignatureNonce=$oncekey&SignatureVersion=1.0&TTL=$ttl_time&Timestamp=$timestamp&Type=$record_type&Value=$ip"
}

# check_aliddns() {
	# current_ip=$(resolve2ip $alidomain)
	# remotecurrent_ip=$(remoteresolve2ip $alidomain)
	
	# echo $(date): "本地接口IP :" ${ip}
	# if [ "Z$remotecurrent_ip" == "Z" ]; then
		# echo $(date): "远程解析IP : 暂无解析记录！"
		# recordid='' # NO Remote Resolve IP Means new Record_ID
	# else
		# if [ "Z$current_ip" == "Z" ]; then
			# echo $(date): "本地解析IP : 本地解析尚未生效！"
			# echo $(date): "远程解析IP :" ${remotecurrent_ip}
		# else
			# if [ "Z$current_ip" != "Z$remotecurrent_ip" ]; then
				# echo $(date): "本地解析IP : 本地解析尚未生效！"
				# echo $(date): "远程解析IP :" ${remotecurrent_ip}
			# else
				# echo $(date): "本地解析IP :" ${current_ip}
				# echo $(date): "远程解析IP :" ${remotecurrent_ip}
			# fi
		# fi
	# fi
	# if [ "Z$ip" == "Z$remotecurrent_ip" ]; then
		# echo $(date): "解析地址一致，无需更新"
		# return 0
	# else
		# echo $(date): "正在检查阿里云解析配置..."
		# return 1
	# fi
# }

check_aliddns() {
    local isrecorded
    echo $(date): "本地接口IP :" ${ip}
    recordvalue=$(query_recordid | jsonfilter -e '@.DomainRecords.Record[*].Value')
    for recordip in $recordvalue
    do
        if [ "Z$recordip" == "Z$ip" ]; then
            isrecorded=1
        fi
        echo $(date): "远程解析IP: $recordip"
    done
    if [ $isrecorded -eq 1 ]; then
		echo $(date): "远程已有该IP记录，无需更新"
		return 0
	else
		echo $(date): "正在检查阿里云解析配置..."
		return 1
	fi
    

}

do_ddns_record() {
	#recordid=`query_recordid | get_recordid`
    local respbody
	if [ "Z$recordid" == "Z" ]; then 
        respbody=$(add_record)
		doaction=1
		echo $(date): "添加记录..."
	else
        respbody=$(update_record $recordid)
		doaction=0
		echo $(date): "更新记录..."
	fi
    recordid=$(echo "$respbody" | get_response_recordid)
	if [ "Z$recordid" == "Z" ]; then
		# failed
        recordmsg=$(echo "$respbody" | get_response_message)
		echo $(date): "更新失败：$recordmsg"
	else
		# save recordid
		uci set koolddns.$alinum.recordid=$recordid
		uci commit koolddns
		if [ "$doaction" == 1 ]; then
			echo $(date): "koolddns添加成功!"
		else
			echo $(date): "koolddns更新成功!"
		fi
	fi
}

[ -x /usr/bin/openssl -a -x /usr/bin/curl -a -x /bin/sed -a -x /usr/bin/date ] ||
	( echo $(date): "Need openssl +bind-dig +curl + sed + coreutils-date to be installed!" && exit 1 )

check_aliddns || do_ddns_record
#!/bin/sh

#################################################
# 由AnripDdns修改而来，原版信息如下：
#################################################
# AnripDdns v5.08
# 基于DNSPod用户API实现的动态域名客户端
# 作者: 若海[mail@anrip.com]
# 介绍: http://www.anrip.com/ddnspod
# 时间: 2016-02-24 16:25:00
# Mod: 荒野无灯 http://ihacklog.com  2016-03-16
#################################################

# ====================================变量定义====================================


timestamp=$(date -u "+%Y-%m-%dT%H%%3A%M%%3A%SZ")

apitoken=$1
domain=$2
name=$3
ip=$4

version=$(cat /etc/openwrt_release 2>/dev/null | grep -w DISTRIB_RELEASE | grep -w "By stones")
version2=$(cat /etc/openwrt_release 2>/dev/null | grep -w DISTRIB_DESCRIPTION | grep -w Koolshare)
[ -z "$version" -a -z "$version2" ] && exit 0

enabled=$(uci -q get koolddns.@global[0].enabled)
[ -z "$enabled" ] && enabled=0
[ "$enabled" -eq 0 ] || [ -z "$apitoken" ] || [ -z "$domain" ] || [ -z "$name" ] || [ -z "$ip" ] && exit

subname=$(echo "$name" | awk -F'.' '{print $1}')
subdomain=$(echo "$name" | awk -F'.' '{print $2}')
if [ "Z$subdomain" == "Z" ]; then
	#add support sencond subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		dnspoddomain=$domain
	elif [ "Z$subname" == "Z*" ]; then
		dnspoddomain=$name.$domain
	else
		dnspoddomain=$name.$domain
	fi
else
	#add support third subdomain and add support */%2A and @/%40 record
	if [ "Z$subname" == "Z@" ]; then
		dnspoddomain=$subdomain.$domain
	elif [ "Z$subname" == "Z*" ]; then
		dnspoddomain=$name.$domain
	else
		dnspoddomain=$name.$domain
	fi
fi

# ====================================函数定义====================================

remoteresolve2ip() {
	#remoteresolve2ip dnspoddomain<string>
	dnspoddomain=$1
	tmp_ip=`drill @f1g1ns1.dnspod.net $dnspoddomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`drill @f1g1ns2.dnspod.net $dnspoddomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	if [ "Z$tmp_ip" == "Z" ]; then
		tmp_ip=`dig @119.29.29.29 $dnspoddomain 2>/dev/null |grep 'IN'|awk -F ' ' '{print $5}'|grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}"|head -n1`
	fi
	echo -n $tmp_ip
}

resolve2ip() {
	#resolve2ip dnspoddomain<string>
	dnspoddomain=$1
	localtmp_ip=`nslookup $dnspoddomain f1g1ns1.dnspod.net 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk '{print $1}'|tail -1`
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $dnspoddomain 119.29.29.29 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk '{print $1}'|tail -1`
	fi
	if [ "Z$localtmp_ip" == "Z" ]; then
		localtmp_ip=`nslookup $dnspoddomain 114.114.115.115 2>/dev/null | sed -n 's/Address 1: \([0-9.]*\)/\1/p'| awk'{print $1}'|tail -1`
	fi
	echo -n $localtmp_ip
}

# 读取接口数据
# 参数: 接口类型 待提交数据
arApiPost() {
    local agent="AnripDdns/5.07(mail@anrip.com)"
    local inter="https://dnsapi.cn/${1:?'Info.Version'}"
    if [ "x${apitoken}" = "x" ]; then # undefine token
        local param="login_email=${arMail}&login_password=${arPass}&format=json&${2}"
    else
        local param="login_token=${apitoken}&format=json&${2}"
    fi
    /usr/bin/wget --quiet --no-check-certificate --output-document=- --user-agent=$agent --post-data $param $inter
}

get_domainid() {
    # Get domain ID
    domainID=$(arApiPost "Domain.Info" "domain=${domain}")
    domainID=$(echo $domainID | sed 's/.*{"id":"\([0-9]*\)".*/\1/')
}

get_recordid() {
	local recordID
	get_domainid
    # Get Record ID
    recordID=$(arApiPost "Record.List" "domain_id=${domainID}&sub_domain=${name}")
    recordID=$(echo $recordID | grep "records\":\[{\"id" | grep "type\":\"A" | sed 's/.*\[{"id":"\([0-9]*\)".*/\1/')
	echo -n $recordID
	
}

add_record() {
	local recordRS
	get_domainid
	# added record
    recordRS=$(arApiPost "Record.Create" "domain_id=${domainID}&sub_domain=${name}&record_type=A&value=${ip}&record_line=默认")
	echo -n $recordRS
}

update_record() {
	local recordRS
	get_domainid
    # Update IP
    recordRS=$(arApiPost "Record.Ddns" "domain_id=${domainID}&record_id=$1&sub_domain=${name}&value=${ip}&record_line=默认")
	echo -n $recordRS
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
	
	recordCD=$(echo $recordRS | sed 's/.*{"code":"\([0-9]*\)".*/\1/')
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
		echo $(date): "错误信息: " `echo $recordRS | sed 's/.*,"message":"\([^"]*\)".*/\1/'`
        return 1
    fi
}

# DDNS Check
# Arg: Main Sub
DdnsCheck() {
	echo $(date): "本地接口IP :" ${ip}
	
	current_ip=$(resolve2ip $dnspoddomain)
    remotecurrent_ip=$(remoteresolve2ip $dnspoddomain)

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
		echo $(date): "正在检查Dnspod解析配置..."
		return 1
	fi

}

# ====================================主逻辑====================================

DdnsCheck || do_ddns_record
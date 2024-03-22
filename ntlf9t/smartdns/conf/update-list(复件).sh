#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

#mkdir -p /tmp/smartdns/

#wget --no-check-certificate https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf  -nv -O /tmp/smartdns/china.conf 
#wget --no-check-certificate https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/apple.china.conf -nv -O /tmp/smartdns/apple.conf
#wget --no-check-certificate https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/google.china.conf -nv -O /tmp/smartdns/google.conf
#合并
#cat /tmp/smartdns/apple.conf >> /tmp/smartdns/china.conf 2>/dev/null
#cat /tmp/smartdns/google.conf >> /tmp/smartdns/china.conf 2>/dev/null

#删除不符合规则的域名
#sed -i "s/^server=\/\(.*\)\/[^\/]*$/nameserver \/\1\/china/g;/^nameserver/!d" /tmp/smartdns/china.conf 2>/dev/null

#mv -f /tmp/smartdns/china.conf  /etc/smartdns/smartdns-domains.china.conf
#mv -f /tmp/smartdns/anti-ad-smartdns.conf  /etc/smartdns/anti-ad-smartdns.conf

#wget --no-check-certificate https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-smartdns.conf -nv -O /tmp/smartdns/anti-ad-smartdns.conf

||adapi.yynetwk.com^
||adashbc.ut.taobao.com^ 使用sed命令改为：address /域名/#:
sed -i 's/^||\(.*\)\^/address \/\1\/#/g;/^address/!d' input.txt

||youxi.kugou.com^
||zeus.ad.xiaomi.com^
/*-ad-*.byteimg.com/
/*-ad-sign.byteimg.com/ 使用sed命令将开头的||和结尾的^及将开头的/和结尾的/改为：address /域名/#:
sed -i 's/^||\(.*\)\^/address \/\1\/#/g; s|^\(.*\)/$|address \1/#|g; /^address/!d'  input.txt 其中：/^address/!d 删除不替换部分


#rm -rf /tmp/smartdns/

# Anti-ad Download Link
# URL="https://github.com/privacy-protection-tools/anti-AD/raw/master/anti-ad-smartdns.conf"
URL="https://anti-ad.net/anti-ad-for-smartdns.conf"

# Smartdns Config File Path
CONFIG_FLODER="/etc/smartdns/domain-set"
CONFIG_FILE="anti-ad-smartdns.conf"

INPUT_FILE=$(mktemp)
OUTPUT_FILE="$CONFIG_FLODER/$CONFIG_FILE"

wget -O $INPUT_FILE $URL
echo "Download successful, updating..."

mkdir -p $CONFIG_FLODER

mv -f $INPUT_FILE $OUTPUT_FILE

chmod 644 $OUTPUT_FILE

# Update China Domain
# source: https://raw.githubusercontent.com/huifukejian/test/master/update-china-list.sh

# 1、China Domain Download Link
##URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
#URL="https://dragonuniform.sg/cnlist.php"

## DNS Server Group
#PROXYDNS_NAME="china"

## Smartdns Config File Path
#CONFIG_FLODER="/etc/smartdns"
#CONFIG_FILE="cnlist.conf"

#INPUT_FILE=$(mktemp)
#OUTPUT_FILE="$CONFIG_FLODER/$CONFIG_FILE"

#if [ "$1" != "" ]; then
#	PROXYDNS_NAME="$1"
#fi

#wget -O $INPUT_FILE $URL 
#echo "Download successful, updating..."

#mkdir -p $CONFIG_FLODER

#sed -i "s/^server=\/\(.*\)\/[^\/]*$/nameserver \/\1\/$PROXYDNS_NAME/g;/^nameserver/!d" $INPUT_FILE 2>/dev/null

#mv -f $INPUT_FILE $OUTPUT_FILE

# Update China Domain
# 2、China Domain Download Link
# URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/direct-list.txt"
URL="https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/direct-list.txt"

# DNS Server Group
PROXYDNS_NAME="CN"

# Smartdns Config File Path
CONFIG_FLODER="/etc/smartdns/domain-set"
CONFIG_FILE="cnlist.conf"

INPUT_FILE=$(mktemp)
OUTPUT_FILE="$CONFIG_FLODER/$CONFIG_FILE"

if [ "$1" != "" ]; then
	PROXYDNS_NAME="$1"
fi

wget -O $INPUT_FILE $URL 
if [ $? -eq 0 ]
then
	echo "Download successful, updating..."
	sed -i "/^$/d;s/\r//g;s/^[ ]*$//g;/^#/d;/regexp:/d;s/full://g" $INPUT_FILE
	mkdir -p $CONFIG_FLODER
	cat /dev/null > $OUTPUT_FILE

	cat $INPUT_FILE | while read line
	do
		echo "nameserver /$line/$PROXYDNS_NAME" >> $OUTPUT_FILE
	done
fi

chmod 644 $OUTPUT_FILE

rm $INPUT_FILE

# GFWlist Download Link
#URL="https://cokebar.github.io/gfwlist2dnsmasq/gfwlist_domain.txt"
# URL="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/gfw.txt"  # 也可使用gfw.txt
URL="https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/gfw.txt"  # 也可使用gfw.txt

# DNS Server Group
PROXYDNS_NAME="overseas"

# Smartdns Config File Path
CONFIG_FLODER="/etc/smartdns/domain-set"
CONFIG_FILE="gfwlist.conf"

INPUT_FILE=$(mktemp)
OUTPUT_FILE="$CONFIG_FLODER/$CONFIG_FILE"

if [ "$1" != "" ]; then
	PROXYDNS_NAME="$1"
fi

wget -O $INPUT_FILE $URL 
if [ $? -eq 0 ]
then
	echo "Download successful, updating..."
	sed -i "/^$/d;s/\r//g;s/^[ ]*$//g;/^#/d;/regexp:/d;s/full://g" $INPUT_FILE
	mkdir -p $CONFIG_FLODER
	cat /dev/null > $OUTPUT_FILE

	cat $INPUT_FILE | while read line
	do
		echo "nameserver /$line/$PROXYDNS_NAME" >> $OUTPUT_FILE
	done
fi

chmod 644 $OUTPUT_FILE

rm $INPUT_FILE

# Update Chnroute

# China IP Download Link
URL="https://ispip.clang.cn/all_cn.txt"

# Smartdns Config File Path
CONFIG_FLODER="/etc/smartdns"
WHITELIST_CONFIG_FILE="whitelist-chnroute.conf"
BLACKLIST_CONFIG_FILE="blacklist-chnroute.conf"

WHITELIST_OUTPUT_FILE="$CONFIG_FLODER/$WHITELIST_CONFIG_FILE"
BLACKLIST_OUTPUT_FILE="$CONFIG_FLODER/$BLACKLIST_CONFIG_FILE"
INPUT_FILE=$(mktemp)
if [ "$1" != "" ]; then
	URL="$1"
fi

wget -O $INPUT_FILE $URL
if [ $? -eq 0 ]
then
	echo "Download successful, updating..."
	mkdir -p $CONFIG_FLODER
	cat /dev/null > $WHITELIST_OUTPUT_FILE
	cat /dev/null > $BLACKLIST_OUTPUT_FILE

	cat $INPUT_FILE | while read line
	do
		echo "whitelist-ip $line" >> $WHITELIST_OUTPUT_FILE
		echo "blacklist-ip $line" >> $BLACKLIST_OUTPUT_FILE
	done
fi

chmod 644 $WHITELIST_OUTPUT_FILE $BLACKLIST_OUTPUT_FILE

rm $INPUT_FILE

#wget --no-check-certificate https://github.com/neodevpro/neodevhost/raw/master/lite_smartdns.conf -nv -O /tmp/smartdns/lite_smartdns.conf
#wget --no-check-certificate https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/gfw.txt -nv -O /tmp/smartdns/gfw.txt

#sed -i "/github*/d" /tmp/smartdns/gfw.txt
#sed -i "/raw.github*/d" /tmp/smartdns/gfw.txt

#mv -f /tmp/smartdns/lite_smartdns.conf /etc/smartdns/anti-ad-for-smartdns.conf
#mv -f /tmp/smartdns/gfw.txt /etc/smartdns/geoip.txt

/etc/init.d/smartdns reload


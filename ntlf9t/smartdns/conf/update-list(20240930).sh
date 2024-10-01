#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

# 更新 Smartdns GFWlist 规则
# source: <https://github.com/LASER-Yi/Dockerfiles/blob/master/smartdns/rootfs/usr/bin/update-gfwlist.sh>
# https://github.com/felixonmars/dnsmasq-china-list

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

#rm -rf /tmp/smartdns/

# Update Chnroute
# China IP4 Download Link
# Smartdns Config File Path

FILE_IPV4="tmp/chnroute.txt"
NAME_IPV4="$(basename $FILE_IPV4)"

CLANG_URL="https://ispip.clang.cn/all_cn.txt"
CLANG_LIST="clang.txt"

CONFIG_FLODER="/etc/smartdns"
WHITELIST_CONFIG_FILE="whitelist-chnroute.conf"
BLACKLIST_CONFIG_FILE="blacklist-chnroute.conf"

WHITELIST_OUTPUT_FILE="$CONFIG_FLODER/$WHITELIST_CONFIG_FILE"
BLACKLIST_OUTPUT_FILE="$CONFIG_FLODER/$BLACKLIST_CONFIG_FILE"

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chnroute.XXXXXX)

function fetch_data() {
  cd $TMP_DIR

  curl -sSL -4 --connect-timeout 10 $CLANG_URL -o $CLANG_LIST

  echo "Download successful, updating..."
  cd $CUR_DIR
}

mkdir -p $CONFIG_FLODER

cat > $WHITELIST_OUTPUT_FILE <<EOF
# Add IP whitelist which you want to filtering from some DNS server here.
# The example below filtering ip from the result of DNS server which is configured with -whitelist-ip.
# whitelist-ip [ip/subnet]
# whitelist-ip 254.0.0.1/16
EOF

cat > $BLACKLIST_OUTPUT_FILE <<EOF
# Add IP blacklist which you want to filtering from some DNS server here.
# The example below filtering ip from the result of DNS server which is configured with -blacklist-ip.
# blacklist-ip [ip/subnet]
# blacklist-ip 254.0.0.1/16
EOF

function gen_ipv4_chnroute() {
  cd $TMP_DIR
	cat $CLANG_LIST | aggregate -q > $NAME_IPV4
		cat $NAME_IPV4 | while read line
	do
		echo "whitelist-ip $line" >> $WHITELIST_OUTPUT_FILE
		echo "blacklist-ip $line" >> $BLACKLIST_OUTPUT_FILE
  done

  cat /dev/null > $CONFIG_FLODER/whitelist-ip.conf
  cat /dev/null > $CONFIG_FLODER/blacklist-ip.conf

  cat $WHITELIST_OUTPUT_FILE >> $CONFIG_FLODER/whitelist-ip.conf
  cat $BLACKLIST_OUTPUT_FILE >> $CONFIG_FLODER/blacklist-ip.conf
  cd $CUR_DIR
}

function clean_up() {
  rm -r $TMP_DIR
  rm -f $WHITELIST_OUTPUT_FILE $BLACKLIST_OUTPUT_FILE
  echo "[chnroute]: OK."
}

fetch_data
gen_ipv4_chnroute
clean_up

# chmod 644 $WHITELIST_OUTPUT_FILE $BLACKLIST_OUTPUT_FILE

/etc/init.d/smartdns reload


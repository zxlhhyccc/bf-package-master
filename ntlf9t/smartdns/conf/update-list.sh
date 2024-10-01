#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

# 更新 Smartdns GFWlist 规则
# Configuration
GFW_LIST="gfwlist.txt"

CONFIG_FOLDER="/etc/smartdns/domain-set"
GFWLIST_CONFIG_FILE="gfwlist.conf"
GFWLIST_OUTPUT_FILE="$CONFIG_FOLDER/$GFWLIST_CONFIG_FILE"

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/gfwlist.XXXXXX)

# Function to fetch GFW list data
function fetch_gfwlist_data() {
  echo "Fetching GFW lists..."
  cd "$TMP_DIR" || exit 1

  # Parallel downloads
  curl -sS https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt | \
    base64 -d | sort -u | sed '/^$\|@@/d' | sed 's#!.\+##; s#|##g; s#@##g; s#http:\/\/##; s#https:\/\/##;' | \
    sed '/apple\.com/d; /sina\.cn/d; /sina\.com\.cn/d; /baidu\.com/d; /qq\.com/d' | \
    sed '/^[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+$/d' | grep '^[0-9a-zA-Z\.-]\+$' | \
    grep '\.' | sed 's#^\.\+##' | sort -u > temp_gfwlist1 &

  curl -sS https://raw.githubusercontent.com/hq450/fancyss/master/rules/gfwlist.conf | \
    sed 's/ipset=\/\.//g; s/\/gfwlist//g; /^server/d' > temp_gfwlist2 &

  curl -sS https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/proxy-list.txt | \
    sed "/^$/d;s/\r//g;s/^[ ]*$//g;/^#/d;/regexp:/d;s/full://g" > temp_gfwlist3 &

  curl -sS https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt > temp_gfwlist4 &

  curl -sS https://raw.githubusercontent.com/ixmu/smartdns-conf/refs/heads/main/script/cust_gfwdomain.conf > temp_gfwlist5 &

  # Wait for all background processes to finish
  wait

  echo "Download successful, updating..."
  cd "$CUR_DIR" || exit 1
}

# Ensure configuration folder exists
mkdir -p "$CONFIG_FOLDER"

# Function to generate the final GFW list
function gen_gfwlist() {
  echo "Generating GFW list..."
  cd "$TMP_DIR" || exit 1

  cat /dev/null > $CONFIG_FOLDER/proxy-domain-list.conf

  # Combine all temp files, clean up, and save to the output file
  cat temp_gfwlist1 temp_gfwlist2 temp_gfwlist3 temp_gfwlist4 temp_gfwlist5 | \
    sort -u | sed 's/^\s*//g; s/\s*$//g' > "$GFW_LIST"

  # Remove empty lines and output to final configuration
  sed -e '/^$/d' "$GFW_LIST" > "$GFWLIST_OUTPUT_FILE"

  # Append to proxy-domain-list.conf
  cat "$GFWLIST_OUTPUT_FILE" >> "$CONFIG_FOLDER/proxy-domain-list.conf"
  cd "$CUR_DIR" || exit 1

  echo "GFW list generated at $GFWLIST_OUTPUT_FILE"
}

# Function to clean up temporary files
function clean_gfwlist_up() {
  echo "Cleaning up..."
  rm -rf "$TMP_DIR"
  rm -f "$GFWLIST_OUTPUT_FILE"
  echo "[gfwlist]: OK."
}

# Run the script steps
fetch_gfwlist_data
gen_gfwlist
clean_gfwlist_up

# 更新 Smartdns chnroute 黑白名单
# China IP4 Download Link
# Smartdns Config File Path

# Configuration
FILE_IPV4="tmp/chnroute.txt"
NAME_IPV4="$(basename "$FILE_IPV4")"

CLANG_LIST="clang.txt"

CONFIG_FOLDER="/etc/smartdns"
WHITELIST_CONFIG_FILE="whitelist-chnroute.conf"
BLACKLIST_CONFIG_FILE="blacklist-chnroute.conf"

WHITELIST_OUTPUT_FILE="$CONFIG_FOLDER/$WHITELIST_CONFIG_FILE"
BLACKLIST_OUTPUT_FILE="$CONFIG_FOLDER/$BLACKLIST_CONFIG_FILE"

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chnroute.XXXXXX)

# Function to fetch China IP route data
function fetch_chnroute_data() {
  echo "Fetching China route data..."
  cd "$TMP_DIR" || exit 1

  # Fetching different IP lists
  qqwry=$(curl -kLfsm 5 https://raw.githubusercontent.com/metowolf/iplist/master/data/special/china.txt)
  ipipnet=$(curl -kLfsm 5 https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt)
  clang=$(curl -kLfsm 5 https://ispip.clang.cn/all_cn.txt)

  # Combine and process IP lists, remove empty lines and duplicates
  iplist="${qqwry}\n${ipipnet}\n${clang}"
  echo -e "$iplist" | sort -u | sed -e '/^$/d' > "$CLANG_LIST"

  # Wait for all background processes to finish
  wait

  echo "Download successful, updating..."
  cd "$CUR_DIR" || exit 1
}

# Ensure config folder exists
mkdir -p "$CONFIG_FOLDER"

# Pre-populate whitelist and blacklist config files
cat > "$WHITELIST_OUTPUT_FILE" <<EOF
# Add IP whitelist which you want to filtering from some DNS server here.
# The example below filtering ip from the result of DNS server which is configured with -whitelist-ip.
# whitelist-ip [ip/subnet]
# whitelist-ip 254.0.0.1/16
EOF

cat > "$BLACKLIST_OUTPUT_FILE" <<EOF
# Add IP blacklist which you want to filtering from some DNS server here.
# The example below filtering ip from the result of DNS server which is configured with -blacklist-ip.
# blacklist-ip [ip/subnet]
# blacklist-ip 254.0.0.1/16
EOF

# Function to generate IPv4 routes for China
function gen_ipv4_chnroute() {
  echo "Generating IPv4 chnroute..."
  cd "$TMP_DIR" || exit 1

  # Aggregate IP ranges and process
  aggregate -q < "$CLANG_LIST" > "$NAME_IPV4"

  # Append to whitelist and blacklist configuration files
  while read -r line; do
    echo "whitelist-ip $line" >> "$WHITELIST_OUTPUT_FILE"
    echo "blacklist-ip $line" >> "$BLACKLIST_OUTPUT_FILE"
  done < "$NAME_IPV4"

  # Write the results to the final configuration files
  cp "$WHITELIST_OUTPUT_FILE" "$CONFIG_FOLDER/whitelist-ip.conf"
  cp "$BLACKLIST_OUTPUT_FILE" "$CONFIG_FOLDER/blacklist-ip.conf"

  cd "$CUR_DIR" || exit 1
  echo "Chnroute generation completed."
}

# Function to clean up temporary files and directories
function clean_chnroute_up() {
  echo "Cleaning up..."
  rm -rf "$TMP_DIR"
  rm -f "$WHITELIST_OUTPUT_FILE" "$BLACKLIST_OUTPUT_FILE"
  echo "[chnroute]: OK."
}

# Execute the functions
fetch_chnroute_data
gen_ipv4_chnroute
clean_chnroute_up

# chmod 644 $WHITELIST_OUTPUT_FILE $BLACKLIST_OUTPUT_FILE

# 更新 Smartdns China List 规则
# Configuration
CHINA_LIST="chinalist.txt"

CONFIG_FOLDER="/etc/smartdns/domain-set"
CHINALIST_CONFIG_FILE="chinaList.conf"
CHINALIST_OUTPUT_FILE="$CONFIG_FOLDER/$CHINALIST_CONFIG_FILE"

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/chinalist.XXXXXX)

# Function to fetch China domain list data
function fetch_chinalist_data() {
  echo "Fetching China domain list data..."
  cd "$TMP_DIR" || exit 1

  # Fetch accelerated domains and direct domains
  accelerated_domains=$(curl -kLfsm 5 https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf)

  curl -sS https://testingcf.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/direct-list.txt | \
    sed "/^$/d;s/\r//g;s/^[ ]*$//g;/^#/d;/regexp:/d;s/full://g" > temp_direct_domains

  # Wait for all background processes to finish
  wait

  echo "Download successful, updating..."
  cd "$CUR_DIR" || exit 1
}

# Ensure the config folder exists
mkdir -p "$CONFIG_FOLDER"

# Function to generate the China domain list
function gen_chinalist() {
  echo "Generating China domain list..."
  cd "$TMP_DIR" || exit 1

  # Prepare the list by combining, sorting, and cleaning the domains
  direct_domains=$(cat temp_direct_domains)
  domain_list="${accelerated_domains}\n${direct_domains}"

  echo -e "$domain_list" | \
    sort | uniq | \
    sed -e 's/#.*//g' -e '/^$/d' -e 's/server=\///g' -e 's/\/114.114.114.114//g' | \
    sort -u > "$CHINALIST_OUTPUT_FILE"

  # Append the final list to the output config
  cp "$CHINALIST_OUTPUT_FILE" "$CONFIG_FOLDER/direct-domain-list.conf"

  cd "$CUR_DIR" || exit 1
  echo "China domain list generation completed."
}

# Function to clean up temporary files
function clean_chinalist_up() {
  echo "Cleaning up..."
  rm -rf "$TMP_DIR"
  rm -f "$CHINALIST_OUTPUT_FILE"
  echo "[chinalist]: OK."
}

# Execute the functions
fetch_chinalist_data
gen_chinalist
clean_chinalist_up

/etc/init.d/smartdns reload


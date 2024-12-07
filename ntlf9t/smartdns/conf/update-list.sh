#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2024 OpenWrt.org

CUR_DIR=$(pwd)
TMP_DIR=$(mktemp -d /tmp/list.XXXXXX)

IP_CONFIG_FOLDER="/etc/smartdns"
LIST_CONFIG_FOLDER="/etc/smartdns/domain-set"

# 确保存放config的文件夹存在
mkdir -p "$(dirname "$IP_CONFIG_FOLDER")"
mkdir -p "$(dirname "$LIST_CONFIG_FOLDER")"

# 更新 Smartdns China List 规则
# 配置
CHINA_LIST="chinalist.txt"

CHINALIST_CONFIG_FILE="chinaList.conf"
CHINALIST_OUTPUT_FILE="$LIST_CONFIG_FOLDER/direct-domain-list.conf"

# 获取中国域名列表数据
function fetch_chinalist() {
    echo "Fetching China domain list data..."
    cd "$TMP_DIR" || exit 1

    # 获取IP列表
    curl -sSl https://fastly.jsdelivr.net/gh/zxlhhyccc/smartdns-list-scripts/direct-domain-list.conf > "$CHINA_LIST"

    # 等待所有后台进程完成
    wait

    echo "Download successful, updating..."
    cd "$CUR_DIR" || exit 1
}

# 生成中国域名列表
function gen_chinalist() {
    echo "Generating China domain list..."
    cd "$TMP_DIR" || exit 1

    # 清空旧列表
    cat /dev/null > "$CHINALIST_OUTPUT_FILE"

    # 删除空行和无效行并输出到最终列表
    sed -e '/^$/d' "$CHINA_LIST" > "$CHINALIST_CONFIG_FILE"

    # 将结果写入最终的配置文件
    cat "$CHINALIST_CONFIG_FILE" >> "$CHINALIST_OUTPUT_FILE"

    cd "$CUR_DIR" || exit 1
    echo "China domain list generation completed."
}

# 执行函数
fetch_chinalist
gen_chinalist

# 更新 Smartdns GFWlist 规则
# 配置
GFW_LIST="temp_gfwlist.txt"

GFWLIST_CONFIG_FILE="gfwlist.conf"
GFWLIST_OUTPUT_FILE="$LIST_CONFIG_FOLDER/proxy-domain-list.conf"

# 获取 GFW 列表数据
function fetch_gfwlist() {
  echo "Fetching GFW lists..."
  cd "$TMP_DIR" || exit 1

  # 下载
  curl -sSl https://fastly.jsdelivr.net/gh/zxlhhyccc/smartdns-list-scripts/proxy-domain-list.conf > "$GFW_LIST"

  # 等待所有后台进程完成
  wait

  echo "Download successful, updating..."
  cd "$CUR_DIR" || exit 1
}

# 生成最终的GFW列表
function gen_gfwlist() {
  echo "Generating GFW list..."
  cd "$TMP_DIR" || exit 1

  # 清空旧列表
  cat /dev/null > "$GFWLIST_OUTPUT_FILE"

  # 删除空行并输出到最终配置
  sed -e '/^$/d' "$GFW_LIST" > "$GFWLIST_CONFIG_FILE"

  # 添加到proxy-domain-list.conf
  cat "$GFWLIST_CONFIG_FILE" >> "$GFWLIST_OUTPUT_FILE"
  cd "$CUR_DIR" || exit 1

  echo "GFW list generation completed."
}

# 执行函数
fetch_gfwlist
gen_gfwlist

# 更新 Smartdns 白名单列表
# 配置
CLANG_LIST="tmp_whitelist.txt"

WHITELIST_CONFIG_FOLDER="/etc/smartdns"
WHITELIST_CONFIG_FILE="whitelist.conf"
WHITELIST_OUTPUT_FILE="$IP_CONFIG_FOLDER/whitelist-ip.conf"

# 获取白名单数据
function fetch_whitelist() {
  echo "Fetching Whitelist Data..."
  cd "$TMP_DIR" || exit 1

  # 获取IP列表
  curl -sSl https://fastly.jsdelivr.net/gh/zxlhhyccc/smartdns-list-scripts/whitelist-ip.conf > "$CLANG_LIST"

  # 等待所有后台进程完成
  wait

  echo "Download successful, updating..."
  cd "$CUR_DIR" || exit 1
}

# 清空旧列表
cat /dev/null > "$WHITELIST_OUTPUT_FILE"

# 预填充白名单配置文件
cat > "$WHITELIST_OUTPUT_FILE" <<EOF
# Add IP whitelist which you want to filtering from some DNS server here.
# The example below filtering ip from the result of DNS server which is configured with -whitelist-ip.
# whitelist-ip [ip/subnet]
# whitelist-ip 254.0.0.1/16
EOF

# 生成白名单列表
function gen_whitelist() {
  echo "Generating Whitelist..."
  cd "$TMP_DIR" || exit 1

  # 处理IP列表，删除空行
  sed -e '/^$/d' "$CLANG_LIST" > "$WHITELIST_CONFIG_FILE"

  # 将结果写入最终的配置文件
  cat "$WHITELIST_CONFIG_FILE" >> "$WHITELIST_OUTPUT_FILE"

  cd "$CUR_DIR" || exit 1
  echo "Whitelist generation completed."
}

# 执行函数
fetch_whitelist
gen_whitelist

# 更新 Smartdns 黑名单列表
BLACK_LIST="tmp_blacklist.txt"

BLACKLIST_CONFIG_FILE="blacklist.conf"
BLACKLIST_OUTPUT_FILE="$IP_CONFIG_FOLDER/blacklist-ip.conf"

# 获取黑名单数据
function fetch_blacklist() {
    echo "Fetching BlackList Data..."
    cd "$TMP_DIR" || exit 1

    # 获取IP列表
    curl -sSl https://fastly.jsdelivr.net/gh/zxlhhyccc/smartdns-list-scripts/blacklist-ip.conf > "$BLACK_LIST"

    # 等待所有后台进程完成
    wait

    echo "Download successful, updating..."
    cd "$CUR_DIR" || exit 1
}

# 清空旧列表
cat /dev/null > "$BLACKLIST_OUTPUT_FILE"

# 预填充黑名单配置文件
cat > "$BLACKLIST_OUTPUT_FILE" <<EOF
# Add IP blacklist which you want to filtering from some DNS server here.
# The example below filtering ip from the result of DNS server which is configured with -blacklist-ip.
# blacklist-ip [ip/subnet]
# blacklist-ip 254.0.0.1/16
EOF

# 生成黑名单列表
function gen_blacklist() {
    echo "Generating BlackList..."
    cd "$TMP_DIR" || exit 1

    # 删除空行和无效行并输出到最终列表
    sed -e '/^$/d' "$BLACK_LIST" > "$BLACKLIST_CONFIG_FILE"

    # 将结果写入最终的配置文件
    cat "$BLACKLIST_CONFIG_FILE" >> "$BLACKLIST_OUTPUT_FILE"

    cd "$CUR_DIR" || exit 1
    echo "BlackList Generation Completed."
}

# 执行函数
fetch_blacklist
gen_blacklist

# chmod 644 $WHITELIST_OUTPUT_FILE $BLACKLIST_OUTPUT_FILE

# 清理临时文件
function clean_up() {
  echo "Cleaning up..."
  rm -rf "$TMP_DIR"
  echo "[list]: OK."
}

# 清理并重启 Smartdns
clean_up

# 重启 SmartDNS 服务
/etc/init.d/smartdns restart


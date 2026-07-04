#!/bin/bash

set -x

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname $0)"; pwd)"

GEOIP_API="https://api.github.com/repos/Loyalsoldier/geoip/releases/latest"
GEOSITE_API="https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest"
GEOSITE_IRAN_API="https://api.github.com/repos/bootmortis/iran-hosted-domains/releases/latest"

function update_geodata() {
    local type="$1"
    local repo="$2"
    local res="$3"
    local tag ver sha line api_url
    
    # 根据类型选择对应的 API
    case "$type" in
        GEOIP)
            api_url="$GEOIP_API"
            ;;
        GEOSITE)
            api_url="$GEOSITE_API"
            ;;
        GEOSITE_IRAN)
            api_url="$GEOSITE_IRAN_API"
            ;;
        *)
            echo "Unknown type: $type"
            return 1
            ;;
    esac
    
    # 获取最新版本号
    tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$api_url" \
           | jq -r ".tag_name")"
    
    if [ -z "$tag" ]; then
        echo "Failed to get tag for $type"
        return 1
    fi
    
    # 获取 Makefile 中的当前版本
    ver="$(awk -F "${type}_VER:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
    
    # 如果版本相同，跳过更新
    if [ "$tag" = "$ver" ]; then
        echo "$type already up to date: $tag"
        return 2
    fi
    
    # 获取 SHA256 校验和
    sha="$(curl -fsSL "https://github.com/$repo/releases/download/$tag/$res" | awk '{print $1}')"
    
    if [ -z "$sha" ]; then
        echo "Failed to get SHA for $type"
        return 1
    fi
    
    # 获取 FILE 行号
    line="$(awk "/FILE:=\\\$\\(${type}_FILE\\)/ {print NR}" "$CURDIR/Makefile")"
    
    if [ -z "$line" ]; then
        echo "Failed to find FILE line for $type"
        return 1
    fi
    
    # 更新 Makefile
    sed -i -e "s/${type}_VER:=.*/${type}_VER:=$tag/" \
           -e "$((line + 1))s/HASH:=.*/HASH:=$sha/" \
           "$CURDIR/Makefile"
    
    echo "Updated $type to $tag (SHA: $sha)"
    return 0
}

# 执行更新
update_geodata "GEOIP" "Loyalsoldier/geoip" "geoip-only-cn-private.dat.sha256sum"
update_geodata "GEOSITE" "Loyalsoldier/v2ray-rules-dat" "geosite.dat.sha256sum"
update_geodata "GEOSITE_IRAN" "bootmortis/iran-hosted-domains" "iran.dat.sha256"

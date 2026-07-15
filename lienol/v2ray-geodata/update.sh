#!/bin/bash

# 开始时开启调试
set -x

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname $0)"; pwd)"

GEOIP_API="https://api.github.com/repos/Loyalsoldier/geoip/releases/latest"
GEOSITE_API="https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest"
GEOSITE_IRAN_API="https://api.github.com/repos/bootmortis/iran-hosted-domains/releases/latest"

NEED_CLEAN=0
UPDATED_TYPES=()
declare -A OLD_VERSIONS
declare -A NEW_VERSIONS
declare -A NEW_SHAS

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# 带颜色的 echo 函数
color_echo() {
    local color="$1"
    local msg="$2"
    echo -e "${color}${msg}${NC}"
}

get_type_name() {
    case "$1" in
        GEOIP)        echo "GeoIP (中国IP列表)" ;;
        GEOSITE)      echo "GeoSite (网站分类)" ;;
        GEOSITE_IRAN) echo "Iran GeoSite (伊朗域名)" ;;
        *)            echo "$1" ;;
    esac
}

get_type_color() {
    case "$1" in
        GEOIP)        echo "$CYAN" ;;
        GEOSITE)      echo "$MAGENTA" ;;
        GEOSITE_IRAN) echo "$YELLOW" ;;
        *)            echo "$WHITE" ;;
    esac
}

function update_geodata() {
    local type="$1"
    local repo="$2"
    local res="$3"
    local tag ver sha line api_url
    local type_name type_color
    
    type_name="$(get_type_name "$type")"
    type_color="$(get_type_color "$type")"
    
    case "$type" in
        GEOIP)        api_url="$GEOIP_API" ;;
        GEOSITE)      api_url="$GEOSITE_API" ;;
        GEOSITE_IRAN) api_url="$GEOSITE_IRAN_API" ;;
        *)
            color_echo "$RED" "[ERROR] Unknown type: $type"
            return 1
            ;;
    esac
    
    color_echo "$BLUE" "--- Checking $type_name ---"
    
    tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$api_url" | jq -r ".tag_name")"
    
    if [ -z "$tag" ] || [ "$tag" = "null" ]; then
        color_echo "$RED" "  ✗ Failed to get tag for $type"
        return 1
    fi
    
    echo -e "  Latest version: ${BOLD}${tag}${NC}"
    
    ver="$(awk -F "${type}_VER:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
    
    if [ -z "$ver" ]; then
        color_echo "$YELLOW" "  ⚠ Current version not found in Makefile"
    else
        echo -e "  Current version: ${BOLD}${ver}${NC}"
    fi
    
    if [ "$tag" = "$ver" ]; then
        color_echo "$GREEN" "  ✓ $type_name already up to date"
        return 2
    fi
 
    NEED_CLEAN=1
    UPDATED_TYPES+=("$type")
    OLD_VERSIONS["$type"]="$ver"
    NEW_VERSIONS["$type"]="$tag"
    
    echo -e "${type_color}  🔄 [UPDATE] $type_name: ${BOLD}${ver}${NC}${type_color} -> ${BOLD}${tag}${NC}"
    
    sha="$(curl -fsSL "https://github.com/$repo/releases/download/$tag/$res" | awk '{print $1}')"
    
    if [ -z "$sha" ]; then
        color_echo "$RED" "  ✗ Failed to get SHA for $type"
        return 1
    fi
    
    NEW_SHAS["$type"]="$sha"
    echo -e "  SHA256: ${WHITE}${sha:0:32}...${NC}"
    
    line="$(awk "/FILE:=\\\$\\(${type}_FILE\\)/ {print NR}" "$CURDIR/Makefile")"
    
    if [ -z "$line" ]; then
        color_echo "$RED" "  ✗ Failed to find FILE line for $type"
        return 1
    fi
    
    sed -i -e "s/${type}_VER:=.*/${type}_VER:=$tag/" \
           -e "$((line + 1))s/HASH:=.*/HASH:=$sha/" \
           "$CURDIR/Makefile"
    
    color_echo "$GREEN" "  ✓ $type_name updated successfully"
    return 0
}

# 打印标题
echo ""
color_echo "$BLUE" "=========================================="
echo -e "${BOLD}${WHITE}  Geo Data Update Script${NC}"
echo -e "  Repository: ${WHITE}$CURDIR${NC}"
color_echo "$BLUE" "=========================================="
echo ""

# 执行更新
update_geodata "GEOIP" "Loyalsoldier/geoip" "geoip-only-cn-private.dat.sha256sum"
update_geodata "GEOSITE" "Loyalsoldier/v2ray-rules-dat" "geosite.dat.sha256sum"
update_geodata "GEOSITE_IRAN" "bootmortis/iran-hosted-domains" "iran.dat.sha256"

echo ""
color_echo "$BLUE" "=========================================="

if [ $NEED_CLEAN -eq 1 ]; then
    echo -e "${BOLD}${YELLOW}=== Changes detected ===${NC}"
    echo ""
    
    # 显示更新详情 - 临时关闭调试
    {
        set +x
        for type in "${UPDATED_TYPES[@]}"; do
            type_name="$(get_type_name "$type")"
            type_color="$(get_type_color "$type")"
            old_ver="${OLD_VERSIONS[$type]}"
            new_ver="${NEW_VERSIONS[$type]}"
            sha="${NEW_SHAS[$type]}"
            
            [ -z "$old_ver" ] && old_ver="(not set)"
            
            printf "${type_color}  %-20s${NC}: ${WHITE}%-12s${NC} ${BOLD}${GREEN}->${NC} ${BOLD}${type_color}%-12s${NC} ${WHITE}(SHA: ${sha:0:16}...)${NC}\n" \
                   "$type_name" "$old_ver" "$new_ver"
        done
        set -x
    }
    
    echo ""
    echo -e "${BOLD}${BLUE}=== Running make clean ===${NC}"
    make package/v2ray-geodata/clean V=s
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${BOLD}${GREEN}=== ✅ Update completed successfully ===${NC}"
    else
        echo ""
        echo -e "${BOLD}${RED}=== ❌ Make clean failed ===${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${BOLD}${CYAN}=== Final versions ===${NC}"
    {
        set +x
        for type in "${UPDATED_TYPES[@]}"; do
            type_name="$(get_type_name "$type")"
            type_color="$(get_type_color "$type")"
            new_ver="${NEW_VERSIONS[$type]}"
            printf "${type_color}  %-20s${NC}: ${BOLD}${WHITE}%s${NC}\n" "$type_name" "$new_ver"
        done
        set -x
    }
else
    echo ""
    echo -e "${BOLD}${GREEN}=== ✅ All geo data already up to date ===${NC}"
fi

color_echo "$BLUE" "=========================================="
echo ""

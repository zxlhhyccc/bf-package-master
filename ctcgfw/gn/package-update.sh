#!/bin/bash
# 自动更新 gn 版本、commit 并计算 HASH

set -e

BUILD_DIR="$(find "$HOME" -maxdepth 3 -type d -name "ax6-6.6" 2>/dev/null | head -n1)"

pushd "$BUILD_DIR" > /dev/null || exit 1

export CURDIR="$(cd "$(dirname "$0")"; pwd)"

REPO="https://gn.googlesource.com/gn.git"
FILE="$CURDIR/src/out/last_commit_position.h"

# 月份转换函数
month_to_num() {
    case "$1" in
        Jan) echo "01" ;;
        Feb) echo "02" ;;
        Mar) echo "03" ;;
        Apr) echo "04" ;;
        May) echo "05" ;;
        Jun) echo "06" ;;
        Jul) echo "07" ;;
        Aug) echo "08" ;;
        Sep) echo "09" ;;
        Oct) echo "10" ;;
        Nov) echo "11" ;;
        Dec) echo "12" ;;
        *) echo "$1" ;;
    esac
}

# 读取旧版本信息
OLD_DATE_FULL=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile" 2>/dev/null || echo "")
OLD_DATE=${OLD_DATE_FULL//-/.}

OLD_COMMIT_FULL=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile" 2>/dev/null || echo "")
OLD_COMMIT=${OLD_COMMIT_FULL:0:8}

OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile" 2>/dev/null || echo "")

# 获取旧的计数
OLD_COUNT="$(awk '/LAST_COMMIT_POSITION_NUM/ {print $3}
     /LAST_COMMIT_POSITION "/ {match($0, /"([0-9]+)/, a); print a[1]}' \
     "$FILE" 2>/dev/null | sort -u | head -1)"

if [ -z "$OLD_COUNT" ]; then
    OLD_COUNT=0
fi

echo "📡 获取最新版本信息..."

# 获取 API 响应并清理
API_RESPONSE=$(curl -s "${REPO}/+log?format=JSON" 2>/dev/null)
if [ -z "$API_RESPONSE" ]; then
    echo "❌ 无法获取 API 响应"
    exit 1
fi

# 移除 Google API 的 XSSI 防护前缀
CLEANED_RESPONSE=$(echo "$API_RESPONSE" | sed '1s/^)]}\x27//' | sed '1s/^)]}'\''//' | sed '1s/^)]}\"\?//')

# 验证 JSON
if ! echo "$CLEANED_RESPONSE" | jq -e . >/dev/null 2>&1; then
    echo "❌ JSON 解析失败，尝试使用 Python..."
    
    # 使用 Python 解析
    COMMIT_FULL=$(echo "$API_RESPONSE" | python3 -c "
import sys, json, re
data = sys.stdin.read()
data = re.sub(r'^\)\]}\'\'', '', data)
data = re.sub(r'^\)\]}\"', '', data)
try:
    json_data = json.loads(data)
    print(json_data['log'][0]['commit'])
except:
    sys.exit(1)
" 2>/dev/null)
    
    if [ -z "$COMMIT_FULL" ]; then
        echo "❌ 无法解析 commit 信息"
        exit 1
    fi
    
    # 使用 Python 解析日期（格式：Wed Aug 13 17:00:00 2026 +0000 -> 2026-08-13）
    API_DATE=$(echo "$API_RESPONSE" | python3 -c "
import sys, json, re, datetime
data = sys.stdin.read()
data = re.sub(r'^\)\]}\'\'', '', data)
data = re.sub(r'^\)\]}\"', '', data)
try:
    json_data = json.loads(data)
    time_str = json_data['log'][0]['committer']['time']
    # 解析: Wed Aug 13 17:00:00 2026 +0000
    parts = time_str.split()
    month = parts[1]
    day = parts[2]
    year = parts[4]
    # 月份转换
    months = {'Jan':'01','Feb':'02','Mar':'03','Apr':'04','May':'05','Jun':'06',
              'Jul':'07','Aug':'08','Sep':'09','Oct':'10','Nov':'11','Dec':'12'}
    month_num = months.get(month, '01')
    print(f'{year}-{month_num}-{day}')
except:
    sys.exit(1)
" 2>/dev/null)
else
    # 使用 jq 解析
    COMMIT_FULL=$(echo "$CLEANED_RESPONSE" | jq -r '.log[0].commit')
    
    # 解析日期：Wed Aug 13 17:00:00 2026 +0000 -> 2026-08-13
    TIME_STR=$(echo "$CLEANED_RESPONSE" | jq -r '.log[0].committer.time')
    MONTH=$(echo "$TIME_STR" | awk '{print $2}')
    DAY=$(echo "$TIME_STR" | awk '{print $3}')
    YEAR=$(echo "$TIME_STR" | awk '{print $5}')
    MONTH_NUM=$(month_to_num "$MONTH")
    API_DATE="${YEAR}-${MONTH_NUM}-${DAY}"
fi

if [ -z "$COMMIT_FULL" ] || [ -z "$API_DATE" ]; then
    echo "❌ 无法获取 commit 或日期信息"
    echo "COMMIT_FULL: $COMMIT_FULL"
    echo "API_DATE: $API_DATE"
    exit 1
fi

LAST_COMMIT=${COMMIT_FULL:0:12}
NEW_DATE=${API_DATE//-/.}
NEW_COMMIT=${COMMIT_FULL:0:8}

echo "📝 最新 commit: $COMMIT_FULL"
echo "📅 日期: $API_DATE"

# 如果版本或 commit 变了，才继续
if [ "$COMMIT_FULL" != "$OLD_COMMIT_FULL" ] && [ -n "$OLD_COMMIT_FULL" ]; then
    echo "⬆️  新版本: $COMMIT_FULL"
    echo "   旧版本: $OLD_COMMIT_FULL"
    
    echo "📊 计算 commit 变更..."
    
    # 获取 commit 数量
    if [ -n "$OLD_COMMIT_FULL" ] && [ "$OLD_COMMIT_FULL" != "$COMMIT_FULL" ]; then
        COUNT_RESPONSE=$(curl -s "${REPO}/+log/${OLD_COMMIT_FULL}..${COMMIT_FULL}?format=JSON" 2>/dev/null)
        COUNT_CLEANED=$(echo "$COUNT_RESPONSE" | sed '1s/^)]}\x27//' | sed '1s/^)]}'\''//' | sed '1s/^)]}\"\?//')
        
        if echo "$COUNT_CLEANED" | jq -e . >/dev/null 2>&1; then
            COUNT=$(echo "$COUNT_CLEANED" | jq -r '.log | length // 0')
        else
            # 使用 Python 备用
            COUNT=$(echo "$COUNT_RESPONSE" | python3 -c "
import sys, json, re
data = sys.stdin.read()
data = re.sub(r'^\)\]}\'\'', '', data)
data = re.sub(r'^\)\]}\"', '', data)
try:
    json_data = json.loads(data)
    print(len(json_data.get('log', [])))
except:
    print(0)
" 2>/dev/null || echo 0)
        fi
        
        NEW_NUM=$((OLD_COUNT + COUNT))
        echo "📊 新增 $COUNT 个 commit，新序号: $NEW_NUM"
    else
        NEW_NUM=$OLD_COUNT
    fi

    # 删除旧源码包
    OLD_TAR="dl/gn-${OLD_DATE}~${OLD_COMMIT}.tar.zst"
    if [ -f "$OLD_TAR" ]; then
        rm -f "$OLD_TAR"
        echo "🗑️  删除旧源码包: $OLD_TAR"
    fi

    # 清理旧缓存
    echo "🧹 清理旧缓存..."
    make package/gn/host/clean V=s 2>/dev/null || true

    # 更新 Makefile
    echo "📝 更新 Makefile..."
    sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATE}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT_FULL}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    # 更新 last_commit_position.h
    if [ -f "$FILE" ]; then
        echo "📝 更新 $FILE..."
        sed -i "$FILE" \
            -e "s/^#define LAST_COMMIT_POSITION_NUM .*/#define LAST_COMMIT_POSITION_NUM ${NEW_NUM}/" \
            -e "s/^#define LAST_COMMIT_POSITION \".*\"/#define LAST_COMMIT_POSITION \"${NEW_NUM} (${LAST_COMMIT})\"/"
    else
        echo "⚠️ 未找到 $FILE"
    fi

    # 重新下载源码包
    echo "📥 下载源码包..."
    make package/gn/download V=s

    # 计算新 hash
    TARFILE="dl/gn-${NEW_DATE}~${NEW_COMMIT}.tar.zst"
    if [ -f "$TARFILE" ]; then
        echo "🔐 计算校验和..."
        CHECKSUM=$(./staging_dir/host/bin/mkhash sha256 "$TARFILE" 2>/dev/null)
        if [ -n "$CHECKSUM" ]; then
            sed -i "$CURDIR/Makefile" \
                -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=${CHECKSUM}|"
            echo "✅ 校验和已更新：$CHECKSUM"
        else
            echo "⚠️ 无法计算校验和"
            exit 1
        fi
    else
        echo "⚠️ 未找到源码包：$TARFILE"
        echo "可用的 dl 目录文件："
        ls -la dl/gn-*.tar.zst 2>/dev/null || echo "  没有 gn 源码包"
        exit 1
    fi
else
    echo "✅ 无需更新，版本和 commit 均一致"
    echo "   当前版本: $OLD_COMMIT_FULL"
fi

popd > /dev/null || exit 1

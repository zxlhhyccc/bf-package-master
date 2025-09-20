#!/bin/bash
# 自动更新 gn 版本、commit 并计算 HASH

set -e

pushd ~/ax6-6.6 || exit 1

export CURDIR="$(cd "$(dirname $0)"; pwd)"

REPO="https://gn.googlesource.com/gn.git"
FILE="$CURDIR/src/out/last_commit_position.h"

OLD_DATE_FULL=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile")
OLD_DATE=${OLD_DATE_FULL//-/.}

OLD_COMMIT_FULL=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=${OLD_COMMIT_FULL:0:8}

OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

OLD_COUNT="$(awk '/LAST_COMMIT_POSITION_NUM/ {print $3}
     /LAST_COMMIT_POSITION "/ {match($0, /"([0-9]+)/, a); print a[1]}' \
     "$FILE" | sort -u)"

OLD_LAST_COMMIT=$(grep 'LAST_COMMIT_POSITION' "$FILE" \
  | grep -oP '\([a-f0-9]{12}\)' \
  | tr -d '()')

API_DATE="$(curl -s "${REPO}/+log?format=JSON" \
  | tail -n +2 \
  | jq -r '.log[0].committer.time' \
  | awk '{print $5 "-" toupper($2) "-" $3}' \
  | sed 's/JAN/01/;s/FEB/02/;s/MAR/03/;s/APR/04/;s/MAY/05/;s/JUN/06/;s/JUL/07/;s/AUG/08/;s/SEP/09/;s/OCT/10/;s/NOV/11/;s/DEC/12/')"
NEW_DATE=${API_DATE//-/.}

COMMIT_FULL="$(curl -s "${REPO}/+log?format=JSON" | tail -n +2 | jq -r '.log[0].commit')"
NEW_COMMIT=${COMMIT_FULL:0:8}
LAST_COMMIT=${COMMIT_FULL:0:12}

COUNT="$(curl -s "${REPO}/+log/${OLD_COMMIT}..${COMMIT_FULL}?format=JSON" \
  | tail -n +2 \
  | jq '.log | length')"

NEW_NUM=$((OLD_COUNT + COUNT))

# 如果版本或 commit 变了，才清除并更新
if [ "$COMMIT_FULL" != "$OLD_COMMIT_FULL" ]; then
    echo "⬆️  新版本: $COMMIT_FULL，旧版本: $OLD_COMMIT_FULL"

    # 删除旧源码包和哈希
    rm -f dl/gn-${OLD_DATE}~${OLD_COMMIT}.tar.zst

    # 清理旧缓存（触发重新编译）
    make package/gn/host/clean V=s

    # 更新 Makefile 中版本、commit 和清空 hash
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATE}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT_FULL}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 更新 last_commit_position.h 中 LAST_COMMIT_POSITION 的计数、commit
    ./staging_dir/host/bin/sed -i "$FILE" \
        -e "s/^#define LAST_COMMIT_POSITION_NUM .*/#define LAST_COMMIT_POSITION_NUM ${NEW_NUM}/" \
        -e "s/^#define LAST_COMMIT_POSITION \".*\"/#define LAST_COMMIT_POSITION \"${NEW_NUM} (${LAST_COMMIT})\"/"

    # 重新下载源码包
    make package/gn/download V=s

    # 计算新 hash
    TARFILE="dl/gn-${NEW_DATE}~${NEW_COMMIT}.tar.zst"
    if [ -f "$TARFILE" ]; then
        CHECKSUM=$(./staging_dir/host/bin/mkhash sha256 "$TARFILE")
        ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
            -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=${CHECKSUM}|"
        echo "✅ 校验和已更新：$CHECKSUM"
    else
        echo "⚠️ 未找到源码包：$TARFILE"
        exit 1
    fi
else
    echo "✅ 无需更新，版本和 commit 均一致"
fi

popd

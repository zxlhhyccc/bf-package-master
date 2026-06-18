#!/bin/bash
# 自动更新 sub-web 版本、commit 并计算 HASH

set -e

BUILD_DIR="$(find "$HOME" -maxdepth 3 -type d -name "ax6-6.6" 2>/dev/null | head -n1)"

pushd "$BUILD_DIR" > /dev/null || exit 1

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_DATE_FULL=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile")
OLD_DATE=${OLD_DATE_FULL//-/.}
OLD_COMMIT_FULL=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=${OLD_COMMIT_FULL:0:8}
OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/CareyWang/sub-web"

API_DATE="$(curl -s https://api.github.com/repos/CareyWang/sub-web/commits \
    | jq -r '.[0].commit.committer.date' \
    | cut -d'T' -f1)"
NEW_DATE=${API_DATE//-/.}

COMMIT_FULL="$(git ls-remote "$REPO" HEAD | cut -f1)"
NEW_COMMIT=${COMMIT_FULL:0:8}

# 如果版本或 commit 变了，才清除并更新
if [ "$API_DATE" != "$OLD_DATE_FULL" ] || \
    [ "$COMMIT_FULL" != "$OLD_COMMIT_FULL" ]; then
    echo "⬆️  新版本: $COMMIT_FULL，旧版本: $OLD_COMMIT_FULL"
    echo "⬆️  新日期: $API_DATE，旧日期: $OLD_DATE_FULL"

    # 删除旧源码包和哈希
    rm -f dl/sub-web-${OLD_DATE}~${OLD_COMMIT}.tar.zst

    # 清理旧缓存（触发重新编译）
    make package/sub-web/clean V=s

    # 更新 Makefile 中版本、commit 和清空 hash
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATE}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT_FULL}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 重新下载源码包
    make package/sub-web/download V=s

    # 计算新 hash
    TARFILE="dl/sub-web-${NEW_DATE}~${NEW_COMMIT}.tar.zst"
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

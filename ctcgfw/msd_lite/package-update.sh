#!/bin/bash
# 自动更新 msd_lite 版本、commit 并计算 HASH

set -e

pushd ~/ax6-6.6 || exit 1

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_DATA=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/rozhuk-im/msd_lite"

API_DATA="$(curl -s https://api.github.com/repos/rozhuk-im/msd_lite/commits \
    | jq -r '.[0].commit.committer.date' \
    | cut -d'T' -f1)"
PKG_DATA="${API_DATA//-/.}"

COMMIT="$(git ls-remote "$REPO" HEAD | cut -f1)"
SHORT_COMMIT=${COMMIT:0:8}

# 如果版本或 commit 变了，才清除并更新
if [ "$API_DATA" != "$OLD_DATA" ] || \
    [ "$COMMIT" != "$OLD_COMMIT" ]; then
    echo "⬆️  新版本: $COMMIT，旧版本: $OLD_COMMIT"
    echo "⬆️  新日期: $API_DATA，旧日期: $OLD_DATA"

    # 删除旧源码包和哈希
    rm -f dl/msd_lite-${PKG_DATA}~${SHORT_COMMIT}.tar.zst

    # 清理旧缓存（触发重新编译）
    make package/msd_lite/clean V=s

    # 修改 Makefile 中的版本和提交哈希
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATA}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 重新下载源码包
    make package/msd_lite/download V=s

    # 重新生成校验和
    TARFILE="dl/msd_lite-${PKG_DATA}~${SHORT_COMMIT}.tar.zst"
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

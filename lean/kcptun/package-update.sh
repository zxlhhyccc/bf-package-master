#!/bin/bash
# 自动更新 kcptun 版本、commit 并计算 HASH

set -e

pushd ~/ax6-6.6 || exit 1

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_VER=$(grep -oP '^PKG_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_DATA=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/xtaci/kcptun"
REPO_API="https://api.github.com/repos/xtaci/kcptun/releases/latest"

# 获取新 TAG、COMMIT 等
TAG="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_API" | jq -r ".tag_name")"
VER="${TAG#v}"  # TAG 形如 v1.8.11

API_DATA="$(curl -s https://api.github.com/repos/xtaci/kcptun/commits \
    | jq -r '.[0].commit.committer.date' \
    | cut -d'T' -f1)"

COMMIT="$(git ls-remote "$REPO" HEAD | cut -f1)"

# 如果版本或 commit 变了，才清除并更新
if [ "$VER" != "$OLD_VER" ] || \
    [ "$API_DATA" != "$OLD_DATA" ] || \
    [ "$COMMIT" != "$OLD_COMMIT" ]; then
    echo "⬆️  新版本: $VER / $COMMIT，旧版本: $OLD_VER / $OLD_COMMIT"
    echo "⬆️  新日期: $API_DATA，旧日期: $OLD_DATA"

    # 删除旧源码包和哈希
    rm -f dl/kcptun-${OLD_VER}.tar.gz

    # 清理旧缓存（触发重新编译）
    make package/kcptun/clean V=s
 
    # 修改 Makefile 中的版本和提交哈希
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_VERSION:=.*|PKG_VERSION:=${VER}|" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATA}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 重新下载源码包
    make package/kcptun/download V=s

    # 重新生成校验和
    TARFILE="dl/kcptun-${VER}.tar.gz"
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

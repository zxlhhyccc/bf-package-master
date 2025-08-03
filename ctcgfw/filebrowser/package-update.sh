#!/bin/bash
# 自动更新 Xray-core 版本、commit 并计算 HASH

set -e

pushd ~/ax6-6.6 || exit 1

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_VER=$(grep -oP '^PKG_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/filebrowser/filebrowser"
REPO_API="https://api.github.com/repos/filebrowser/filebrowser/releases/latest"

# 获取新 TAG、COMMIT 等
TAG="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_API" | jq -r ".tag_name")"
COMMIT="$(git ls-remote "$REPO" HEAD | cut -f1)"
VER="${TAG#v}"  # TAG 形如 v1.8.11

# 如果版本或 commit 变了，才清除并更新
if [ "$VER" != "$OLD_VER" ] || [ "$COMMIT" != "$OLD_COMMIT" ]; then
    echo "新版本: $VER / $COMMIT，旧版本: $OLD_VER / $OLD_COMMIT"
    
    # 修改 Makefile 中的版本和提交哈希
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_VERSION:=.*|PKG_VERSION:=${VER}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|"

    # 删除旧源码包和哈希
    rm -f dl/filebrowser-${OLD_VER}.tar.zst

    # 清理旧缓存（触发重新编译）
    make package/filebrowser/clean V=s

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    # 重新下载源码包
    make package/filebrowser/download V=s

    # 重新生成校验和
    TARFILE="dl/filebrowser-${VER}.tar.zst"
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

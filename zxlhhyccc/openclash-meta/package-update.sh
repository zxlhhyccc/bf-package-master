#!/bin/bash
# 自动更新 openclash-meta 版本、commit 并计算 HASH

set -e

pushd ~/ax6-6.6 || exit 1

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_COMMIT_FULL=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=${OLD_COMMIT_FULL:0:8}

OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/MetaCubeX/mihomo"

# 获取新 COMMIT
COMMIT="$(git ls-remote "$REPO" "refs/heads/Alpha" | cut -f1)"

# 如果 commit 变了，才清除并更新
if [ "$COMMIT" != "$OLD_COMMIT_FULL" ]; then
    echo "⬆️  新版本:: $COMMIT，旧版本: $OLD_COMMIT_FULL"

    # 删除旧源码包和哈希
    rm -f dl/openclash-meta-alpha-${OLD_COMMIT}.tar.zst

    # 清理旧缓存（触发重新编译）
    make package/openclash-meta/clean V=s

    # 修改 Makefile 中的版本和提交哈希
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 重新下载源码包
    make package/openclash-meta/download V=s

    # 重新生成校验和
    TARFILE="dl/openclash-meta-alpha-${OLD_COMMIT}.tar.zst"
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

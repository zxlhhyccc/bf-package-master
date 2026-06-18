#!/bin/bash
# 自动更新 Xray-core 版本、commit 并计算 HASH

set -e

BUILD_DIR="$(find "$HOME" -maxdepth 3 -type d -name "ax6-6.6" 2>/dev/null | head -n1)"

pushd "$BUILD_DIR" > /dev/null || exit 1

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_VER=$(grep -oP '^PKG_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_DATA=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/v2fly/v2ray-core"
REPO_API="https://api.github.com/repos/v2fly/v2ray-core/releases/latest"

# 获取新 TAG、DATA、COMMIT 等
TAG="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_API" | jq -r ".tag_name")"
API_VER="${TAG#v}"  # TAG 形如 v1.8.11

# 获取 Git 仓库中最新的 tag（严格排序）
LATEST_TAG=$(git ls-remote --tags "$REPO" | \
    grep -o 'refs/tags/.*' | sed 's#refs/tags/##' | grep -v '{}' | \
    sort -V | tail -n1)
LATEST_VER="${LATEST_TAG#v}"  # LATEST_TAG 形如 v1.8.11

API_DATA=$(curl -s https://api.github.com/repos/v2fly/v2ray-core/commits \
    | jq -r '.[0].commit.committer.date' \
    | cut -d'T' -f1)

COMMIT="$(git ls-remote "$REPO" HEAD | cut -f1)"

# 判断使用哪个版本号
if [ "$API_VER" != "$LATEST_VER" ]; then
    echo "⚠️ API 返回的版本 $API_VER 不等于最新标签 $LATEST_VER，使用最新标签"
    USE_VER="$LATEST_VER"
else
    USE_VER="$API_VER"
fi

# 如果版本或 commit 变了，才清除并更新
if [ "$USE_VER" != "$OLD_VER" ] || \
    [ "$API_DATA" != "$OLD_DATA" ] || \
    [ "$COMMIT" != "$OLD_COMMIT" ]; then
    echo "⬆️  新版本: $USE_VER / $COMMIT，旧版本: $OLD_VER / $OLD_COMMIT"
    echo "⬆️  新日期: $API_DATA，旧日期: $OLD_DATA"

    # 删除旧源码包和哈希
    rm -f dl/v2ray-core-v5-${OLD_VER}.tar.gz

    # 清理旧缓存（触发重新编译）
    make package/v2ray-core-v5/clean V=s

    # 修改 Makefile 中的版本和提交哈希
    sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_VERSION:=.*|PKG_VERSION:=${USE_VER}|" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATA}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 重新下载源码包
    make package/v2ray-core-v5/download V=s

    # 重新生成校验和
    TARFILE="dl/v2ray-core-v5-${USE_VER}.tar.gz"
    if [ -f "$TARFILE" ]; then
        CHECKSUM=$(./staging_dir/host/bin/mkhash sha256 "$TARFILE")
        sed -i "$CURDIR/Makefile" \
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

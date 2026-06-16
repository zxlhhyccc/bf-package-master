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

REPO="https://github.com/XTLS/Xray-core"
REPO_API="https://api.github.com/repos/XTLS/Xray-core/releases/latest"
REPO_COMMITS_API="https://api.github.com/repos/xtls/xray-core/commits"

echo "🔍 正在检查远程仓库状态..."

# 获取 GitHub API 返回的 tag、data 和 commit
TAG="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_API" \
    | jq -r '(if type == "array" then .[0] else . end) | .tag_name // "error"')"

if [ "$TAG" = "error" ] || [ -z "$TAG" ]; then
    echo "⚠️ 错误: 无法获取合法的远程版本号，自动更新终止。"
    exit 1
fi

API_VER="${TAG#v}"  # TAG 形如 v1.8.11

# 获取 Git 仓库中最新的 tag（严格排序）
LATEST_TAG="$(git ls-remote --tags "$REPO" | \
    grep -o 'refs/tags/.*' | sed 's#refs/tags/##' | grep -v '{}' | \
    sort -V | tail -n1)"
LATEST_VER="${LATEST_TAG#v}"  # LATEST_TAG 形如 v1.8.11

API_DATA="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_COMMITS_API" \
    | jq -r '(if type == "array" then .[0] else . end) | .commit.committer.date // "error"' \
    | cut -d'T' -f1)"

if [ "$API_DATA" = "error" ] || [ -z "$API_DATA" ]; then
    echo "⚠️ 错误: 无法从远程仓库获取合法的提交日期，自动更新终止。"
    exit 1
fi

# 判断使用哪个版本号
if [ "$API_VER" != "$LATEST_VER" ]; then
    echo "⚠️ API 返回的版本 $API_VER 不等于最新标签 $LATEST_VER，使用最新标签"
    USE_VER="$LATEST_VER"
else
    USE_VER="$API_VER"
fi

# 获取最新 Commit ID
COMMIT="$(git ls-remote "$REPO" HEAD | cut -f1)"

# 如果版本或 commit 变了，才清除并更新
if [ "$USE_VER" != "$OLD_VER" ] || \
    [ "$API_DATA" != "$OLD_DATA" ] || \
    [ "$COMMIT" != "$OLD_COMMIT" ]; then
    echo "⬆️  新版本: $USE_VER / $COMMIT，旧版本: $OLD_VER / $OLD_COMMIT"
    echo "⬆️  新日期: $API_DATA，旧日期: $OLD_DATA"


    # 执行清理（利用未破坏的 Makefile 防止卡死）
    echo "🧹 正在清理旧编译缓存..."
    make package/xray-core/clean V=s

    # 删除旧源码包和哈希
    echo "🧹 正在清理旧源码包和哈希..."
    rm -f dl/xray-core-${OLD_VER}.tar.gz

    # 更新 Makefile 中版本、commit 和清空 hash
    sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_VERSION:=.*|PKG_VERSION:=${USE_VER}|" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATA}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    echo "📥 正在下载新源码包..."
    make package/xray-core/download V=s

    # 计算新 hash
    TARFILE="dl/xray-core-${USE_VER}.tar.gz"
    if [ -f "$TARFILE" ]; then
        CHECKSUM=$(./staging_dir/host/bin/mkhash sha256 "$TARFILE")
        sed -i "$CURDIR/Makefile" \
            -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=${CHECKSUM}|"
        echo "✅ 自动更新圆满完成！新 HASH: $CHECKSUM"
    else
        echo "⚠️ 错误: 未找到下载的源码包: $TARFILE"
        exit 1
    fi
else
    echo "✅ 无需更新，本地 Commit ($OLD_VER) 与远程一致。"
fi

popd

#!/bin/bash
# 自动更新 openclash-meta 版本、commit 并计算 HASH

set -e

BUILD_DIR="$(find "$HOME" -maxdepth 3 -type d -name "ax6-6.6" 2>/dev/null | head -n1)"

pushd "$BUILD_DIR" > /dev/null || exit 1

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname $0)"; pwd)"

OLD_VER=$(grep -oP '^PKG_BASE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT_FULL=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=${OLD_COMMIT_FULL:0:8}

OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/MetaCubeX/mihomo"
REPO_API="https://api.github.com/repos/MetaCubeX/mihomo/releases/latest"

# 获取 GitHub API 返回的 tag、data 和 commit
TAG="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_API" | jq -r ".tag_name")"
API_VER="${TAG#v}"  # TAG 形如 v1.8.11

# 获取新 COMMIT
COMMIT="$(git ls-remote "$REPO" "refs/heads/Alpha" | cut -f1)"
NEW_COMMIT=${COMMIT:0:8}

# 如果 commit 变了，才清除并更新
if [ "$API_VER" != "$OLD_VER" ] || \
    [ "$COMMIT" != "$OLD_COMMIT_FULL" ]; then
    echo "⬆️  新版本: $API_VER / $COMMIT，旧版本: $OLD_VER / $OLD_COMMIT_FULL"

    # 删除旧源码包和哈希
    rm -f dl/openclash-meta-${OLD_VER}~${OLD_COMMIT}.tar.zst

    # 清理旧缓存（触发重新编译）
    make package/openclash-meta/clean V=s

    # 修改 Makefile 中的版本和提交哈希
    sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_BASE_VERSION:=.*|PKG_BASE_VERSION:=${API_VER}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    # 重新下载源码包
    make package/openclash-meta/download V=s

    # 重新生成校验和
    TARFILE="dl/openclash-meta-${API_VER}~${NEW_COMMIT}.tar.zst"
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

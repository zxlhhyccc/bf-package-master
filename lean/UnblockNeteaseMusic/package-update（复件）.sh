#!/bin/bash
# 自动更新 UnblockNeteaseMusic 版本、commit 并计算 HASH

set -e

BUILD_DIR="$(find "$HOME" -maxdepth 3 -type d -name "ax6-6.6" 2>/dev/null | head -n1)"
pushd "$BUILD_DIR" > /dev/null || exit 1

export CURDIR="$(cd "$(dirname "$0")"; pwd)"

# 1. 提取本地 Makefile 中的旧数据
OLD_VER=$(grep -oP '^PKG_BASE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_DATA=$(grep -oP '^PKG_SOURCE_DATE:=\K.*' "$CURDIR/Makefile")
OLD_COMMIT=$(grep -oP '^PKG_SOURCE_VERSION:=\K.*' "$CURDIR/Makefile")
OLD_SHORT_COMMIT=${OLD_COMMIT:0:8} 
OLD_CHECKSUM=$(grep -oP '^PKG_MIRROR_HASH:=\K.*' "$CURDIR/Makefile")

REPO="https://github.com/UnblockNeteaseMusic/server"
REPO_RELEASE_LIST="https://api.github.com/repos/UnblockNeteaseMusic/server/releases"
REPO_COMMITS_API="https://api.github.com/repos/UnblockNeteaseMusic/server/commits"

echo "🔍 正在检查远程仓库状态..."

# 2. 优先通过不限流的 ls-remote 获取最新 Commit ID (最快且安全)
COMMIT="$(git ls-remote "$REPO" HEAD | cut -f1)"
SHORT_COMMIT=${COMMIT:0:8}

# 3. 核心逻辑：只有当远程 Commit 和本地不一致时，才触发更新和 API 请求
if [ "$COMMIT" != "$OLD_COMMIT" ]; then

    # 4. 🟢 移到 if 内部：此时百分百确定有更新，再精准请求 GitHub API 获取版本号和日期
    echo " 发现新提交，正在获取版本和日期明细..."
    
    # 获取最新 Tag
    TAG_JSON="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_RELEASE_LIST")"
    TAG="$(echo "$TAG_JSON" | jq -r 'if type == "array" and length > 0 then .[0].tag_name else empty end')"
    [ -z "$TAG" ] && { echo "⚠️ 错误: 无法获取 Release Tag，可能触发 GitHub 限流或 Token 失效。"; exit 1; }
    VER="${TAG#v}"

    # 获取最新 Commit 日期
    COMMITS_JSON=$(curl -H "Authorization: $GITHUB_TOKEN" -sL "$REPO_COMMITS_API")
    API_DATA=$(echo "$COMMITS_JSON" | jq -r 'if type == "array" and length > 0 then .[0].commit.committer.date[0:10] else "error" end')

    if [ "$API_DATA" = "error" ] || [ -z "$API_DATA" ]; then
        echo "⚠️ 错误: 提取新日期失败。接口返回内容:"
        echo "$COMMITS_JSON" | jq -r '.message // "未知错误"'
        exit 1
    fi

    # 打印版本变更明细
    echo "⬆️  新版本: $VER / $COMMIT，旧版本: $OLD_VER / $OLD_COMMIT"
    echo "⬆️  新日期: $API_DATA，旧日期: $OLD_DATA"

    # 5. 执行清理（利用未破坏的 Makefile 防止卡死）
    echo "🧹 正在清理旧编译缓存..."
    make package/UnblockNeteaseMusic/clean V=s
    rm -f dl/UnblockNeteaseMusic-${OLD_VER}-${OLD_DATA}-${OLD_SHORT_COMMIT}.tar.zst

    # 6. 修改 Makefile 变量
    ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
        -e "s|^PKG_BASE_VERSION:=.*|PKG_BASE_VERSION:=${VER}|" \
        -e "s|^PKG_SOURCE_DATE:=.*|PKG_SOURCE_DATE:=${API_DATA}|" \
        -e "s|^PKG_SOURCE_VERSION:=.*|PKG_SOURCE_VERSION:=${COMMIT}|" \
        -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"

    echo "🧹 清空旧 HASH：$OLD_CHECKSUM"

    echo "📥 正在下载新源码包..."
    make package/UnblockNeteaseMusic/download V=s

    # 7. 重新生成并填入校验和
    TARFILE="dl/UnblockNeteaseMusic-${VER}-${API_DATA}-${SHORT_COMMIT}.tar.zst"
    if [ -f "$TARFILE" ]; then
        CHECKSUM=$(./staging_dir/host/bin/mkhash sha256 "$TARFILE")
        ./staging_dir/host/bin/sed -i "$CURDIR/Makefile" \
            -e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=${CHECKSUM}|"
        echo "✅ 自动更新圆满完成！新 HASH: $CHECKSUM"
    else
        echo "⚠️ 错误: 未找到下载的源码包: $TARFILE"
        exit 1
    fi
else
    echo "✅ 无需更新，本地 Commit ($OLD_SHORT_COMMIT) 与远程一致。"
fi

popd > /dev/null

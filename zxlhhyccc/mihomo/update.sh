#!/bin/bash

set -x

if [ -z "$GITHUB_TOKEN" ] && [ -f ".git-credentials" ]; then
    GITHUB_TOKEN=$(grep -oP 'https://[^:]+:\K[^@]+' ".git-credentials" | head -n1)
fi

export CURDIR="$(cd "$(dirname $0)"; pwd)"

function update() {
	local type="$1"
	local repo="$2"
	local tag ver sha old_hash line commit old_ver

	# 获取最新版本号
	API_VER="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" \
		| jq -r '(if type == "array" then .[0] else . end) | .tag_name // "error"')"
	tag="${API_VER#v}"
	[ -n "$tag" ] || return 1
	
	# 获取当前版本号
	ver="$(awk -F "PKG_VERSION:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
	old_ver="$ver"
	
	# 如果版本相同，不需要更新
	if [ "$tag" = "$ver" ]; then
		echo "✅ 版本已是最新: $ver"
		return 2
	fi
	
	echo "📦 发现新版本: $old_ver -> $tag"
	
	# ========== 清理旧编译缓存 ==========
	echo "🧹 正在清理旧编译缓存..."
	
	# 清理指定包的编译缓存
	if [ -n "$type" ]; then
		make package/${type}/clean V=s 2>/dev/null || echo "⚠️ 无法执行 make clean，跳过"
	fi
	
	# ========== 清理旧源码包 ==========
	echo "🧹 正在清理旧源码包和哈希..."
	
	# 清理旧版本的源码包
	if [ -n "$type" ]; then
		rm -f "dl/${type}-${old_ver}.tar.gz" 2>/dev/null
	fi
	
	# ========== 更新 Makefile ==========
	echo "📝 更新 Makefile..."
	
	# 更新版本号
	line="$(awk "/PKG_VERSION:=/ {print NR}" "$CURDIR/Makefile")"
	sed -i -e "$((line))s/PKG_VERSION:=.*/PKG_VERSION:=$tag/" "$CURDIR/Makefile"

	echo "🧹 清空旧 HASH..."
	sed -i "$CURDIR/Makefile" \
		-e "s|^PKG_MIRROR_HASH:=.*|PKG_MIRROR_HASH:=|"
	
	# 获取新的 SHA256
	echo "🔍 获取源码 SHA256..."
	make package/$type/download V=s
	
	# 修正：使用 pkg_name 和 tag 构造文件名，注意语法
	TARFILE="dl/${type}-${tag}.tar.gz"
	
	if [ -f "$TARFILE" ]; then
		sha="$(sha256sum "$TARFILE" | awk '{print $1}')"
		echo "✅ 文件存在: $TARFILE"
	else
		echo "❌ 下载失败：$TARFILE 不存在"
		# 尝试查找可能的文件名
		echo "📂 当前 dl 目录内容："
		ls -la "dl/" 2>/dev/null || echo "dl 目录不存在或为空"
		return 1
	fi
	
	[ -n "$sha" ] || return 1
	
	old_sha="$(awk -F "PKG_MIRROR_HASH:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
	line="$(awk "/PKG_MIRROR_HASH:=/ {print NR}" "$CURDIR/Makefile")"
	
	if [ "$sha" != "$old_sha" ]; then
		sed -i -e "$((line))s/PKG_MIRROR_HASH:=.*/PKG_MIRROR_HASH:=$sha/" "$CURDIR/Makefile"
		echo "✅ SHA256 已更新"
	else
		echo "⚠️ SHA256 未变化"
	fi
	
	# 获取最新 commit
	commit="$(git ls-remote https://github.com/$repo.git HEAD | cut -f1)"
	
	echo "=========================================="
	echo "✅ 更新完成！"
	echo "  📦 包名: $type"
	echo "  🔢 旧版本: $old_ver"
	echo "  🔢 新版本: $tag"
	echo "  🔑 SHA256: $sha"
	echo "  📝 Commit: $commit"
	echo "=========================================="
}

# 执行更新
update "mihomo" "MetaCubeX/mihomo"

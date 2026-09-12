#!/bin/bash
set -euo pipefail

CURDIR="$(cd "$(dirname "$0")" && pwd)"

# 1. 获取最新版本
NEW_VERSION="$(curl -fsSL http://dl-cn.verysync.com/releases/ \
  | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' \
  | sed 's/^v//' \
  | sort -V \
  | tail -n1)"

[ -n "$NEW_VERSION" ] || exit 1

OLD_VERSION="$(sed -n 's/^PKG_VERSION:=//p' "$CURDIR/Makefile")"

[ "$OLD_VERSION" != "$NEW_VERSION" ] || exit 0

echo "Update version: $OLD_VERSION → $NEW_VERSION"

# 2. ARCH → verysync arch 映射
ARCH_MAP="
aarch64 arm64
arm     arm
i386    386
mips    mips
mipsel  mipsle
powerpc64 ppc64le
x86_64  amd64
"

# 3. 一次性拉取 sha256sum.txt 到变量（不落地）
SHA_URL="https://dl-cn.verysync.com/releases/v${NEW_VERSION}/sha256sum.txt"
echo "Fetch checksum list: $SHA_URL"

SHA_LIST="$(curl -kfsSL "$SHA_URL")" || {
  echo "Failed to download sha256sum.txt" >&2
  exit 1
}

# 4. 逐架构从变量中提取 HASH
while read -r arch vs_arch; do
  [ -z "$arch" ] && continue

  filename="verysync-linux-${vs_arch}-v${NEW_VERSION}.tar.gz"

  # sha256sum 标准格式: "<hash>  <filename>"
  sha256="$(printf '%s\n' "$SHA_LIST" | awk -v f="$filename" '$2 == f {print $1; exit}')"

  if [ -z "$sha256" ]; then
    echo "HASH not found for $filename" >&2
    exit 1
  fi

  echo "$arch ($vs_arch): $sha256"

  # 精确替换该 ARCH block 内的 HASH
  sed -i "/ifeq (\$(ARCH),${arch})/,/else ifeq\|endif/{
    s/^\\([[:space:]]*PKG_HASH_VERYSYNC:=\\).*/\\1${sha256}/
  }" "$CURDIR/Makefile"

done <<< "$ARCH_MAP"

# 5. 更新版本号
sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${NEW_VERSION}/" "$CURDIR/Makefile"

echo "Done."

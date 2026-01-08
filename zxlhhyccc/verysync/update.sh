#!/bin/bash
set -euo pipefail

CURDIR="$(cd "$(dirname "$0")" && pwd)"

# 1. 获取最新版本
NEW_VERSION="$(curl -fsSL http://dl.verysync.com/releases/ \
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
powerpc64 ppc64
x86_64  amd64
"

# 3. 逐架构更新 HASH
while read -r arch vs_arch; do
  [ -z "$arch" ] && continue

  url="http://dl.verysync.com/releases/v${NEW_VERSION}/verysync-linux-${vs_arch}-v${NEW_VERSION}.tar.gz"
  echo "Fetch: $url"

  sha256="$(curl -fsSL "$url" | sha256sum | awk '{print $1}')" || exit 1

  # 精确替换该 ARCH block 内的 HASH
  sed -i "/ifeq (\$(ARCH),${arch})/,/else ifeq\|endif/{
    s/^\\([[:space:]]*PKG_HASH_VERYSYNC:=\\).*/\\1${sha256}/
  }" "$CURDIR/Makefile"

done <<< "$ARCH_MAP"

# 4. 更新版本号
sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${NEW_VERSION}/" "$CURDIR/Makefile"

echo "Done."


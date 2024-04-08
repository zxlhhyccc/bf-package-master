#!/bin/bash

set -x

export CURDIR="$(cd "$(dirname $0)"; pwd)"

# 获取版本号
function update_version() {
	local type="$1"
	local repo="$2"
	local tag ver line

	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name")"
	[ -n "$tag" ] || return 1

        ver="$(awk -F 'PKG_VERSION:=' '/PKG_VERSION:/{gsub("\"","",$2);print $2}' "$CURDIR/Makefile")"

	[ "$tag" != "$ver" ] || return 2
	
	line="$(awk "/PKG_VERSION:=/ {print NR}" "$CURDIR/Makefile")"
	sed -i -e "$((line))s/PKG_VERSION:=.*/PKG_VERSION:=$tag/" "$CURDIR/Makefile"
}

update_version "chinadns-ng"  "zfl9/chinadns-ng"

# 获取哈希值
if grep -qE "aarch64|arm|mips|mipsel" "$CURDIR/Makefile"; then
function _update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local reg="$4"
	local tag sha old_sha line

	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name")"
	[ -n "$tag" ] && {
	sha="$(curl -sL https://github.com/$repo/releases/download/$tag/chinadns-ng@${type}@${res}+${reg}@fast+lto | sha256sum | awk '{print $1}')"

	[ -n "$sha" ] || return 1

	line="$(awk "/PKG_ARCH:=chinadns-ng@${type}@${res}\+${reg}@fast\+lto/ {print NR}" "$CURDIR/Makefile")"
	
	old_sha="$(awk -F "PKG_HASH:=" -v next_line="$((line + 1))" 'NR==next_line {print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$sha" != "$old_sha" ] || return 2

	sed -i -e "$((line + 1))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"
	}
}

_update "aarch64-linux-musl" "zfl9/chinadns-ng" "generic" "v8a"
_update "arm-linux-musleabi" "zfl9/chinadns-ng" "generic" "v6+soft_float"
_update "arm-linux-musleabihf" "zfl9/chinadns-ng" "generic" "v7a"
_update "mips-linux-musl" "zfl9/chinadns-ng" "mips32" "soft_float"
_update "mipsel-linux-musl" "zfl9/chinadns-ng" "mips32" "soft_float"
fi

if grep -qE "arm" "$CURDIR/Makefile"; then
function musleabi_update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local reg="$4"
	local regs="$5"
	local tag sha old_sha line

	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name")"
	[ -n "$tag" ] && {
	sha="$(curl -sL https://github.com/$repo/releases/download/$tag/chinadns-ng@${type}@${res}+${reg}+${regs}@fast+lto | sha256sum | awk '{print $1}')"

	[ -n "$sha" ] || return 1

	line="$(awk "/PKG_ARCH:=chinadns-ng@${type}@${res}\+${reg}\+${regs}@fast\+lto/ {print NR}" "$CURDIR/Makefile")"
	
	old_sha="$(awk -F "PKG_HASH:=" -v next_line="$((line + 1))" 'NR==next_line {print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$sha" != "$old_sha" ] || return 2

	sed -i -e "$((line + 1))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"
	}
}

musleabi_update "arm-linux-musleabi" "zfl9/chinadns-ng" "generic" "v6" "soft_float"
fi

if grep -qE "i386|x86_64" "$CURDIR/Makefile"; then
function update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local tag sha old_sha line

	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name")"
	[ -n "$tag" ] && {
	sha="$(curl -sL https://github.com/$repo/releases/download/$tag/chinadns-ng@${type}@${res}@fast+lto | sha256sum | awk '{print $1}')"

	[ -n "$sha" ] || return 1

	line="$(awk "/PKG_ARCH:=chinadns-ng@${type}@${res}@fast\+lto/ {print NR}" "$CURDIR/Makefile")"

	old_sha="$(awk -F "PKG_HASH:=" -v next_line="$((line + 1))" 'NR==next_line {print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$sha" != "$old_sha" ] || return 2	

	sed -i -e "$((line + 1))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"
	}
}

update "i386-linux-musl" "zfl9/chinadns-ng" "i686"
update "x86_64-linux-musl" "zfl9/chinadns-ng" "x86_64"
fi

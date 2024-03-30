#!/bin/bash

set -x

export CURDIR="$(cd "$(dirname $0)"; pwd)"

function update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local tag sha old_hash line

	sha="$(curl -sL http://download.qt.io/official_releases/qt/${repo}/${repo}.${res}/submodules/${type}-everywhere-src-${repo}.${res}.tar.xz | sha256sum | awk '{print $1}')"
	[ -n "$sha" ] || return 1

	old_hash="$(awk -F "PKG_HASH:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
	line="$(awk "/PKG_HASH:=/ {print NR}" "$CURDIR/Makefile")"	
	[ "$sha" != "$old_hash" ] || return 2
	
	   sed -i -e "$((line))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"
}

update "qttools" "$(awk -F "PKG_BASE:=" '{print $2}' "$CURDIR/Makefile" | xargs)" "$(awk -F "PKG_BUGFIX:=" '{print $2}' "$CURDIR/Makefile" | xargs)"

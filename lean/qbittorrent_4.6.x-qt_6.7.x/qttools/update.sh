#!/bin/bash

set -x

export CURDIR="$(cd "$(dirname $0)"; pwd)"

function update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local NEW_BASE NEW_BUGFIX sha old_hash line_base line_bugfix 

	NEW_BASE="$(curl -fsSL https://download.qt.io/${repo}/ \
	   | grep -o '>[0-9]\+\.[0-9]\+/' \
	   | sed 's/[>/]//g' \
	   | sort -V \
	   | tail -n1)"

	NEW_BUGFIX="$(curl -fsSL https://download.qt.io/${repo}/${NEW_BASE}/ \
	   | grep -o '>[0-9]\+\.[0-9]\+\.[0-9]\+/' \
	   | sed 's/[>/]//g' \
	   | sort -V \
	   | tail -n1 \
	   | awk -F. '{print $NF}')"

	[ -n "$NEW_BASE.$NEW_BUGFIX" ] || return 1

	OLD_BASE="$(awk -F "PKG_BASE:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
	OLD_BUGFIX="$(awk -F "PKG_BUGFIX:=" '{print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$NEW_BASE.$NEW_BUGFIX" != "$OLD_BASE.$OLD_BUGFIX" ] || return 2

	line_base="$(awk "/PKG_BASE:=/ {print NR}" "$CURDIR/Makefile")"
	sed -i -e "$((line_base))s/PKG_BASE:=.*/PKG_BASE:=$NEW_BASE/" "$CURDIR/Makefile"
	line_bugfix="$(awk "/PKG_BUGFIX:=/ {print NR}" "$CURDIR/Makefile")"
	sed -i -e "$((line_bugfix))s/PKG_BUGFIX:=.*/PKG_BUGFIX:=$NEW_BUGFIX/" "$CURDIR/Makefile"

	sha="$(curl -fsSL http://download.qt.io/${repo}/${NEW_BASE}/$NEW_BASE.$NEW_BUGFIX/submodules/${type}-everywhere-src-$NEW_BASE.$NEW_BUGFIX.tar.xz | sha256sum | awk '{print $1}')"
	[ -n "$sha" ] || return 1

	old_hash="$(awk -F "PKG_HASH:=" '{print $2}' "$CURDIR/Makefile" | xargs)"
	line="$(awk "/PKG_HASH:=/ {print NR}" "$CURDIR/Makefile")"	
	[ "$sha" != "$old_hash" ] || return 2
	
	   sed -i -e "$((line))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"
}

update "qttools" "official_releases/qt" "$(awk -F "PKG_BASE:=" '{print $2}' "$CURDIR/Makefile" | xargs)"

#!/bin/bash

set -x

export CURDIR="$(cd "$(dirname $0)"; pwd)"

function update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local tag ver sha old_hash line frontend_sha frontend_old_sha commit

	# 获取版本号
	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name" | sed 's/v//')"
	[ -n "$tag" ] || return 1

        ver="$(awk -F "PKG_VERSION:=" '{print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$tag" != "$ver" ] || return 2
	
	line="$(awk "/PKG_VERSION:=/ {print NR}" "$CURDIR/Makefile")"
	sed -i -e "$((line))s/PKG_VERSION:=.*/PKG_VERSION:=$tag/" "$CURDIR/Makefile"

	# 获取哈希值
	sha="$(curl -sL https://codeload.github.com/$repo/tar.gz/v$tag | shasum -a 256 | awk '{print $1}')"
	[ -n "$sha" ] || return 1

        old_sha=="$(awk -F "PKG_HASH:=" '{print $2}' "$CURDIR/Makefile" | xargs)"

	line="$(awk "/PKG_HASH:=/ {print NR}" "$CURDIR/Makefile")"	
	[ "$sha" != "$old_sha" ] || return 2
	
	   sed -i -e "$((line))s/PKG_HASH:=.*/PKG_HASH:=$sha/" "$CURDIR/Makefile"

	# 获取AdGuardHome-frontend值
	frontend_sha="$(curl -sL https://github.com/$repo/releases/download/v$tag/AdGuardHome_frontend.tar.gz | shasum -a 256 | awk '{print $1}')"
	[ -n "$frontend_sha" ] || return 1

	line="$(awk "/FILE:=\\$\(${res}_FILE\)/ {print NR}" "$CURDIR/Makefile")"

        frontend_old_sha="$(awk -F "HASH:=" -v next_line="$((line + 1))" 'NR==next_line {print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$frontend_sha" != "$frontend_old_sha" ] || return 3

	sed -i -e "$((line + 1))s/HASH:=.*/HASH:=$frontend_sha/" "$CURDIR/Makefile"

	# 获取commit值
	  commit="$(git ls-remote  https://github.com/$repo.git beta-v0.107 | cut -f1)"
}

update "AdGuardHome" "AdguardTeam/AdGuardHome" "FRONTEND"


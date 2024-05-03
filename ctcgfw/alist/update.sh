#!/bin/bash

set -x

export CURDIR="$(cd "$(dirname $0)"; pwd)"

function update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local tag ver sha old_hash line

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

	# 获取commit值
	  commit="$(git ls-remote  https://github.com/$repo.git main | cut -f1)"

}

update "alist" "alist-org/alist" "alist"

# 获取alist-web值
function _update() {
	local type="$1"
	local repo="$2"
	local res="$3"
	local tag ver line alist_sha alist_old_sha commit

	tag="$(curl -H "Authorization: $GITHUB_TOKEN" -sL "https://api.github.com/repos/$repo/releases/latest" | jq -r ".tag_name" | sed 's/v//')"	
	# [ -n "$tag" ] && {

	alist_sha="$(curl -sL https://github.com/$repo/releases/download/$tag/dist.tar.gz | sha256sum | awk '{print $1}')"

	[ -n "$alist_sha" ] || return 1

	line="$(awk "/FILE:=\\$\((WEB_FILE)\)/ {print NR}" "$CURDIR/Makefile")"

        alist_old_sha="$(awk -F "HASH:=" -v next_line="$((line + 1))" 'NR==next_line {print $2}' "$CURDIR/Makefile" | xargs)"

	[ "$alist_sha" != "$alist_old_sha" ] || return 3

	sed -i -e "$((line + 1))s/HASH:=.*/HASH:=$alist_sha/" "$CURDIR/Makefile"
	# }
}

_update "alist" "alist-org/alist-web" "alist-web"



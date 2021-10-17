#!/bin/sh

dir=$(uci get verysync.setting.device)
more=$(uci get verysync.setting.more)

rm -rf "$dir/.verysync"
rm -rf verysync*.tar.gz
[ -h  /usr/bin/verysync ] && rm -rf  /usr/bin/verysync
uci set verysync.setting.more=0
uci commit verysync

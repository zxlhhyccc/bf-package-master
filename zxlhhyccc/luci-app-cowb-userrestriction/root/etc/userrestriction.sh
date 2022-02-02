#!/bin/bash

if [ "$(uci get userrestriction.@basic[0].enabled 2>/dev/null)" == 1 ] && [ "$(cat /etc/config/userrestriction|grep -c 'option enable .1.')" -gt 0 ]; then

check_1() {
sleep 1
iptables -w -C FORWARD -j userrestriction 2>/dev/null && ip6tables -w -C FORWARD -j userrestriction 2>/dev/null || /etc/init.d/userrestriction start
}

while :
do
sleep 10
iptables -w -C FORWARD -j userrestriction 2>/dev/null && ip6tables -w -C FORWARD -j userrestriction 2>/dev/null || check_1
done

fi

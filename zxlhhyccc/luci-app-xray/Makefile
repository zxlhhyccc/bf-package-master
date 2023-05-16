#
# Copyright (C) 2020-2023 honwen https://github.com/honwen
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-xray
PKG_VERSION:=0.7.1
PKG_RELEASE:=1
PKG_MAINTAINER:=honwen <https://github.com/honwen>

LUCI_TITLE:=LuCI Support for Xray
LUCI_DEPENDS:=+iptables +ipset +curl +ip +iptables-mod-tproxy
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/config/xray
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-xray ]; then
		( . /etc/uci-defaults/luci-xray ) && \
		rm -f /etc/uci-defaults/luci-xray
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature

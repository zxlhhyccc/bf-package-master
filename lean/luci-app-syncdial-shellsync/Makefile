#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Virtual WAN config generator
LUCI_DEPENDS:=+kmod-macvlan +shellsync +luci-app-mwan3 +luci-compat
PKG_VERSION:=20170513
PKG_RELEASE:=1
PKG_MAINTAINER:=monokoo

define Package/$(PKG_NAME)/conffiles
	/etc/config/syncdial
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-syncdial ]; then
		( . /etc/uci-defaults/luci-syncdial ) && rm -f /etc/uci-defaults/luci-syncdial
	fi
	rm -rf /tmp/luci-indexcache
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature
#Makefile for syncdial

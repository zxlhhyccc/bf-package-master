# Copyright (C) 2019 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for qBittorrent
LUCI_DEPENDS:=+qbittorrent
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-qbittorrent
PKG_RELEASE:=$(AUTORELEASE)

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

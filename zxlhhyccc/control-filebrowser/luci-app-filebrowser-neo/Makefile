# Copyright (C) 2018-2020 Lienol <lawlienol@gmail.com>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#
# Improve by xiaozhuai <xiaozhuai7@gmail.com>
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for FileBrowser
LUCI_DEPENDS:=+filebrowser-neo +luci-lua-runtime
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-filebrowser-neo
PKG_VERSION:=0.0.3
PKG_RELEASE:=1


include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

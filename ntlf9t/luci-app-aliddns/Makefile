#
# Copyright (C) 2018-2024 honwen <https://github.com/honwen/>
#
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI Support for aliddns
LUCI_DESCRIPTION:=LuCI Support for ALiDDNS.
LUCI_DEPENDS:=+openssl-util +curl
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-aliddns
PKG_VERSION:=0.4.2
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=honwen <https://github.com/honwen/>

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

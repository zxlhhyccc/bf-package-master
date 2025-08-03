# This is free software, licensed under the Apache License, Version 2.0

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-nat6-helper
PKG_VERSION:=v1.0
PKG_RELEASE:=1

PKG_LICENSE:=MIT License
PKG_MAINTAINER:=<https://github.com/Ausaci/luci-app-nat6-helper>

LUCI_TITLE:=LuCI support for NAT6
LUCI_DEPENDS:=@IPV6 \
	+ip6tables \
	+ip6tables-mod-nat \
	+ip6tables-extra
LUCI_PKGARCH:=all

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature



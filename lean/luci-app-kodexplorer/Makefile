#
# Copyright (C) 2018-2026 Lienol <lawlienol@gmail.com>
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for KodExplorer
LUCI_PKGARCH:=all
LUCI_DEPENDS:= \
	+nginx-ssl \
	+unzip \
	+zoneinfo-asia \
	+php8 \
	+php8-fastcgi \
	+php8-fpm

PKG_VERSION:=20220109
PKG_RELEASE:=2

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature


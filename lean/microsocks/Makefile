# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=microsocks
PKG_VERSION=1.0.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rofl0r/microsocks.git
PKG_SOURCE_DATE:=2022-02-02
PKG_SOURCE_VERSION:=375e5a66d7ea444405c2bc3e4f6b450b3a9bfa39
PKG_MIRROR_HASH:=7c0d375e2ca2a1eb46b4e506033d56e990bcfae3c0817dc884fe7ad8508bec65

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=lean

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/microsocks
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Tiny, portable SOCKS5 server
  URL:=https://github.com/rofl0r/microsocks
  DEPENDS:=+libpthread
endef

define Package/microsocks/description
  A SOCKS5 service that you can run on your remote boxes to tunnel connections
  through them, if for some reason SSH doesn't cut it for you.
endef

define Package/microsocks/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/bin/microsocks $(1)/usr/bin/microsocks
endef

$(eval $(call BuildPackage,microsocks))

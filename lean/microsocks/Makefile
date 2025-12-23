# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=microsocks
PKG_VERSION:=1.0.5
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rofl0r/microsocks/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=939d1851a18a4c03f3cc5c92ff7a50eaf045da7814764b4cb9e26921db15abc8

#PKG_SOURCE_PROTO:=git
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://github.com/rofl0r/microsocks.git
#PKG_SOURCE_DATE:=2022-09-18
#PKG_SOURCE_VERSION:=655c53d27df0bd69e0ecfa8309ce2940797f3362
#PKG_MIRROR_HASH:=d047882cf489a8408c8d870f583f9263779dc6a8ec11da1e106fc5684aceb5f7

PKG_MAINTAINER:=Mateusz Korniak <matkorgithubcom@ant.gliwice.pl>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=lean

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_BUILD_FLAGS:=lto

include $(INCLUDE_DIR)/package.mk

define Package/microsocks
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Tiny, portable SOCKS5 server. Support forwarding rules
  URL:=https://github.com/rofl0r/microsocks
  DEPENDS:=+libpthread
endef

define Package/microsocks/description
  A SOCKS5 service that you can run on your remote boxes to tunnel connections
  through them, if for some reason SSH doesn't cut it for you.
  This version supports forwarding rules.
endef

define Package/microsocks/conffiles
/etc/config/microsocks
endef

# TARGET_CFLAGS+= -flto
# TARGET_LDFLAGS+= -flto -Wl,--gc-sections,--as-needed

TARGET_CFLAGS += -Wno-unknown-pragmas
TARGET_LDFLAGS+= -Wl,--gc-sections,--as-needed

define Package/microsocks/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/microsocks $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/microsocks.config $(1)/etc/config/microsocks
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/microsocks.init $(1)/etc/init.d/microsocks
endef

$(eval $(call BuildPackage,microsocks))

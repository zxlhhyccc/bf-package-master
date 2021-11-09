#
# Copyright (C) 2019 Daniel Bermond
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=proxychains-ng
PKG_VERSION:=4.15
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rofl0r/proxychains-ng.git
PKG_SOURCE_VERSION:=7de7dd0de1ff387a627620ac3482b4cd9b3fba95
PKG_MIRROR_HASH:=b651ba27141c38e181d0c16f8fbf1b9ded46343b82d73933159323222b4cbe22

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/proxychains-ng
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Redirect TCP traffic to a HTTP or SOCKS proxy
  URL:=https://github.com/rofl0r/proxychains/
endef

define Package/proxychains-ng/description
  A hook preloader that allows to redirect TCP traffic of
  existing dynamically linked programs through one or more
  SOCKS or HTTP proxies.
endef

define Build/Compile
	$(call Build/Compile/Default,all)
endef

define Build/Install
	$(call Build/Install/Default,install install-config)
endef

define Package/proxychains-ng/conffiles
/etc/proxychains.conf
endef

define Package/proxychains-ng/install
	# binary executable
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/proxychains4 $(1)/usr/bin/
	$(LN) proxychains4 $(1)/usr/bin/proxychains
	
	# library
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libproxychains4.so $(1)/usr/lib/
	
	# config
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/proxychains.conf $(1)/etc/
endef

$(eval $(call BuildPackage,proxychains-ng))

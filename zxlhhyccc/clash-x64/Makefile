#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clash-x64
PKG_VERSION:=v0.17.1
PKG_MAINTAINER:=frainzy1477

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=clash-x64
	DEPENDS:=
	URL:=https://github.com/frainzy1477/clash_dev/releases
endef

define Package/$(PKG_NAME)/description
clash is a cross-platform proxy software
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/openclash
	$(INSTALL_BIN) ./files/clash $(1)/etc/openclash/clash
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

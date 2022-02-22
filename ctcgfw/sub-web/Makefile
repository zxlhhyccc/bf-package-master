#
# Copyright (C) 2021 ImmortalWrt
# (https://immortalwrt.org)
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=sub-web
PKG_VERSION:=1.0.0
PKG_RELEASE:=6

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/CareyWang/sub-web.git
PKG_SOURCE_DATE:=2022-02-19
PKG_SOURCE_VERSION:=68b9b929dd5c95749216cd4329f871d0fb9d620a
PKG_MIRROR_HASH:=196222ca6588b890d06b31516ad9e1ea23ebf0ec97ab9636e6b57427242d6bc2

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=node/host node-yarn/host

include $(INCLUDE_DIR)/package.mk

define Package/sub-web
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/CareyWang/sub-web
  TITLE:=A WebUI for generating proxy subscription url
  DEPENDS:=+subconverter
  PKGARCH:=all
endef

define Package/sub-web/description
  Based on vue-cli and subconverter, for generating proxy subscription
  url automatically.
endef

define Build/Compile
	( \
		cd $(PKG_BUILD_DIR); \
		yarn install; \
		yarn build; \
	)
endef

define Package/sub-web/install
	$(INSTALL_DIR) $(1)/www
	$(CP) $(PKG_BUILD_DIR)/dist $(1)/www/sub-web
endef

$(eval $(call BuildPackage,sub-web))

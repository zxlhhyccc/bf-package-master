# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=UnblockNeteaseMusic
PKG_BASE_VERSION:=0.27.0-beta.8
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/UnblockNeteaseMusic/server.git
PKG_SOURCE_DATE:=2021-10-31
PKG_SOURCE_VERSION:=c43b7ba30bb14ccd0170fe529d96054328c8dfd2
PKG_MIRROR_HASH:=2ae02f09b5b2152b633ffe424f6c683d5ba77396f5d368e99e6d68f8a39f6263

PKG_VERSION:=$(PKG_BASE_VERSION)-$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))

PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/UnblockNeteaseMusic
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Revive Netease Cloud Music (NodeJS)
  URL:=https://github.com/nondanee/UnblockNeteaseMusic
  DEPENDS:=+node
  PKGARCH:=all
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	xzcat $(DL_DIR)/$(PKG_SOURCE) | $(TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

define Build/Configure
	echo -e $(PKG_BASE_VERSION) > $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/core_ver
	echo -e $(PKG_SOURCE_VERSION) > $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/local_ver
endef

define Build/Compile
endef

define Package/UnblockNeteaseMusic/install
	$(INSTALL_DIR) $(1)/usr/share/UnblockNeteaseMusic
	$(CP) $(PKG_BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/* $(1)/usr/share/UnblockNeteaseMusic
endef

$(eval $(call BuildPackage,UnblockNeteaseMusic))

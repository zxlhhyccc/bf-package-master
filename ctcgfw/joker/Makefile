# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=joker
PKG_VERSION:=20220126
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/txthinking/joker/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=565cb7cf476cc46f61a506676660f46d9db4689f5c32e60df7e560b72a0102e8

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

include $(INCLUDE_DIR)/package.mk

define Package/joker
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Run command as daemon
  URL:=https://github.com/txthinking/joker
  DEPENDS:=+libc
endef

define Package/joker/description
  Joker can turn process into daemon. Zero-Configuration.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		$(PKG_BUILD_DIR)/{main,run}.c -o $(PKG_BUILD_DIR)/joker
endef

define Package/joker/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/joker $(1)/usr/bin/
endef
$(eval $(call BuildPackage,joker))

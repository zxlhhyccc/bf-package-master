#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openclash
PKG_VERSION:=v0.20.0
PKG_RELEASE:=

ifeq ($(ARCH),mipsel)
	OPENCLASH_ARCH:=mipsle-softfloat
endif
ifeq ($(ARCH),mips)
	OPENCLASH_ARCH:=mips64
endif
ifeq ($(ARCH),i386)
	OPENCLASH_ARCH:=386
endif
ifeq ($(ARCH),x86_64)
	OPENCLASH_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	OPENCLASH_ARCH:=armv7
endif
ifeq ($(BOARD),bcm53xx)
	OPENCLASH_ARCH:=armv5
endif
ifeq ($(BOARD),kirkwood)
	OPENCLASH_ARCH:=armv5
endif
ifeq ($(ARCH),aarch64)
	OPENCLASH_ARCH:=arm64
endif

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/clash-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE:=clash-linux-$(OPENCLASH_ARCH).tar.gz
PKG_SOURCE_URL:=https://github.com/vernesong/OpenClash/releases/download/Clash
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=openclash is a cross-platform proxy software
	DEPENDS:=
	URL:=https://github.com/frainzy1477/clash_dev/releases
endef

define Package/$(PKG_NAME)/description
openclash is a cross-platform proxy software
endef

define Build/Prepare
	tar -xzvf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clash $(1)/etc/openclash/core/clash
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-tun
PKG_VERSION:=v0.18.0
PKG_RELEASE:=8-g68b82c9

ifeq ($(ARCH),mipsel)
	OPENCLASH_TUN_ARCH:=mipsle-softfloat
endif
ifeq ($(ARCH),mips)
	OPENCLASH_TUN_ARCH:=mips64
endif
ifeq ($(ARCH),i386)
	OPENCLASH_TUN_ARCH:=386
endif
ifeq ($(ARCH),x86_64)
	OPENCLASH_TUN_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	OPENCLASH_TUN_ARCH:=armv7
endif
ifeq ($(BOARD),bcm53xx)
	OPENCLASH_TUN_ARCH:=armv5
endif
ifeq ($(BOARD),kirkwood)
	OPENCLASH_TUN_ARCH:=armv5
endif
ifeq ($(ARCH),aarch64)
	OPENCLASH_TUN_ARCH:=arm64
endif

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/clash-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE:=clash-linux-$(OPENCLASH_TUN_ARCH)-$(PKG_VERSION)-$(PKG_RELEASE).gz
PKG_SOURCE_URL:=https://github.com/Dreamacro/clash/releases/download/TUN
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=openclash-tun is a cross-platform proxy software
	DEPENDS:=+kmod-tun
	URL:=https://github.com/frainzy1477/clash_dev/releases
endef

define Package/$(PKG_NAME)/description
openclash-tun is a cross-platform proxy software
endef

define Build/Prepare
	gzip -d -k -f -c $(DL_DIR)/$(PKG_SOURCE) > $(PKG_BUILD_DIR)/clash-tun
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clash-tun $(1)/etc/openclash/core/clash_tun
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

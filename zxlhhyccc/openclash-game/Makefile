#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-game
PKG_VERSION:=v0.17.0
PKG_RELEASE:=214-g89f5710

ifeq ($(ARCH),mipsel)
	OPENCLASH_GAME_ARCH:=mipsle-softfloat
endif
ifeq ($(ARCH),mips)
	OPENCLASH_GAME_ARCH:=mips64
endif
ifeq ($(ARCH),i386)
	OPENCLASH_GAME_ARCH:=386
endif
ifeq ($(ARCH),x86_64)
	OPENCLASH_GAME_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	OPENCLASH_GAME_ARCH:=armv7
endif
ifeq ($(BOARD),bcm53xx)
	OPENCLASH_GAME_ARCH:=armv6
ifeq ($(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE)))),)
	OPENCLASH_GAME_ARCH:=armv5
endif
endif
ifeq ($(BOARD),kirkwood)
	OPENCLASH_GAME_ARCH:=armv5
endif
ifeq ($(ARCH),aarch64)
	OPENCLASH_GAME_ARCH:=arm64
endif

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/clash-$(PKG_VERSION)-$(PKG_RELEASE)
PKG_SOURCE:=clash-linux-$(OPENCLASH_GAME_ARCH).tar.gz
PKG_SOURCE_URL:=https://github.com/vernesong/OpenClash/releases/download/TUN/
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=openclash-game is a cross-platform proxy software
	DEPENDS:=+kmod-tun
	URL:=https://github.com/frainzy1477/clash_dev/releases
endef

define Package/$(PKG_NAME)/description
openclash-game is a cross-platform proxy software
endef

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/clash-linux-$(OPENCLASH_GAME_ARCH).tar.gz ] && wget https://github.com/vernesong/OpenClash/releases/download/TUN/clash-linux-$(OPENCLASH_GAME_ARCH).tar.gz -O $(PKG_BUILD_DIR)/clash-linux-$(OPENCLASH_GAME_ARCH).tar.gz
	tar -xzvf $(PKG_BUILD_DIR)/clash-linux-$(OPENCLASH_GAME_ARCH).tar.gz -C $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clash $(1)/etc/openclash/core/clash_game
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

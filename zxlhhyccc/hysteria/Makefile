# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021-2021  sirpdboy  <herboy2008@gmail.com>
# 
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=1.3.5
PKG_RELEASE:=1

ifeq ($(ARCH),mipsel)
	HYSTERIA_ARCH:=mipsle
endif
ifeq ($(ARCH),x86_64)
	HYSTERIA_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	HYSTERIA_ARCH:=arm
endif
ifeq ($(BOARD),bcm53xx)
	HYSTERIA_ARCH:=arm
ifeq ($(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE)))),)
	HYSTERIA_ARCH:=armv5
endif
endif
ifeq ($(BOARD),kirkwood)
	HYSTERIA_ARCH:=armv5
endif
ifeq ($(ARCH),aarch64)
	HYSTERIA_ARCH:=arm64
endif

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=ZXLHHYCCC <zxlhhy@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_HYSTERIA_COMPRESS_UPX

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=57c5164854d6cfe00bead730cce731da2babe406

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=Hysteria is a feature-packed network utility optimized for networks of poor quality (e.g. satellite connections, congested public Wi-Fi, connecting from China to servers abroad)
	DEPENDS:=@(x86_64||arm||aarch64||mipsel)
	URL:=https://github.com/apernet/hysteria
endef

define Package/$(PKG_NAME)/description
  Hysteria is a feature-packed network utility optimized for networks of poor quality (e.g. satellite connections, congested public Wi-Fi, connecting from China to servers abroad)
endef

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/$(PKG_NAME)-linux-$(HYSTERIA_ARCH) ] && wget https://github.com/apernet/hysteria/releases/download/v$(PKG_VERSION)/$(PKG_NAME)-linux-$(HYSTERIA_ARCH) -O $(PKG_BUILD_DIR)/$(PKG_NAME)-linux-$(HYSTERIA_ARCH)
	chmod +x $(PKG_BUILD_DIR)/$(PKG_NAME)-linux-$(HYSTERIA_ARCH)
endef

define Package/$(PKG_NAME)/config
config HYSTERIA_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

define Build/Compile
	true
ifeq ($(CONFIG_HYSTERIA_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/$(PKG_NAME)-linux-$(HYSTERIA_ARCH)
endif
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME)-linux-$(HYSTERIA_ARCH) $(1)/usr/bin/hysteria
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

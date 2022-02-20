# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=brook
PKG_VERSION:=20210701
PKG_RELEASE:=$(AUTORELEASE)

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/txthinking/brook/tar.gz/v$(PKG_VERSION)?
#PKG_HASH:=a8e2e989f6d09e36c1fbe8593404d53a0615dc93e91a0be94dda898f0d55ff1d

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/txthinking/brook.git
PKG_SOURCE_VERSION:=d060ac86bdde5800a4fe2f0ee1531c3d4e464334
PKG_MIRROR_HASH:=73dd86e1a93db3c559ff85fab12e0bcb3d1a81d7c32a0d02835e02048ca8bc80

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_BROOK_COMPRESS_GOPROXY \
	CONFIG_BROOK_COMPRESS_UPX

GO_PKG:=github.com/txthinking/brook
GO_PKG_BUILD_PKG:=github.com/txthinking/brook/cli/brook
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/brook
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=A cross-platform proxy software
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  URL:=https://github.com/txthinking/brook
endef

define Package/brook/description
  Brook is a cross-platform strong encryption and not detectable proxy.
  Zero-Configuration.
endef

define Package/brook/config
	config BROOK_COMPRESS_GOPROXY
		bool "Compiling with GOPROXY proxy"
		default n

	config BROOK_COMPRESS_UPX
		bool "Compress executable files with UPX"
		depends on !mips64
		default n
endef

ifeq ($(CONFIG_BROOK_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_BROOK_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/brook
endif
endef

$(eval $(call GoBinPackage,brook))
$(eval $(call BuildPackage,brook))

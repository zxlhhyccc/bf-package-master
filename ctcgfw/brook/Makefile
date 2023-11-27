# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=brook
PKG_VERSION:=20230606
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/txthinking/brook/tar.gz/v$(PKG_VERSION)?
#PKG_HASH:=a8e2e989f6d09e36c1fbe8593404d53a0615dc93e91a0be94dda898f0d55ff1d

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/txthinking/brook.git
PKG_SOURCE_DATE:=2023-11-23
PKG_SOURCE_VERSION:=0ea4efe9234f3bd874d2e600ff946c8f77fc00a1
PKG_MIRROR_HASH:=4c691a9a2d54e529583e8fd988e8350e6240658092286fb39aa01dec908dcdae

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
# PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

PKG_CONFIG_DEPENDS:= \
	CONFIG_BROOK_COMPRESS_GOPROXY \
	CONFIG_BROOK_COMPRESS_UPX

GO_PKG:=github.com/txthinking/brook
GO_PKG_BUILD_PKG:=$(GO_PKG)/cli/brook
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

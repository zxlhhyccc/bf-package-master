# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2009-2013 OpenWrt.org
#

include $(TOPDIR)/rules.mk

PKG_NAME:=BaiduPCS-Go
PKG_VERSION:=3.9.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/qjfoidnh/BaiduPCS-Go/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5c4990a488a742c52b5429546bccccd9f195c7889cdef5d86ac1b28c95fc7e6c

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_BAIDUPCS_GO_COMPRESS_GOPROXY \
	CONFIG_BAIDUPCS_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/qjfoidnh/BaiduPCS-Go
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/BaiduPCS-Go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Download Manager
  TITLE:=Terminal utility for Baidu Network Disk
  URL:=https://github.com/qjfoidnh/BaiduPCS-Go
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/BaiduPCS-Go/config
config BAIDUPCS_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config BAIDUPCS_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_BAIDUPCS_GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_BAIDUPCS_GO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/BaiduPCS-Go
endif
endef

define Package/BaiduPCS-Go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/BaiduPCS-Go $(1)/usr/bin/
endef

$(eval $(call GoBinPackage,BaiduPCS-Go))
$(eval $(call BuildPackage,BaiduPCS-Go))

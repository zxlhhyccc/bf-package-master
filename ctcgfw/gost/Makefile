# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gost
PKG_VERSION:=2.11.4
PKG_RELEASE:=$(AUTORELEASE)

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/ginuerzh/gost/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=d94b570a7a84094376b8c299d740528f51b540d9162f1db562247a15a89340bf

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/ginuerzh/gost.git
PKG_SOURCE_VERSION:=005cff5888160aa3137c691ae414d4c34019389f
PKG_MIRROR_HASH:=eb45c32d535645e4e7f0d2ca0c12ac642c4c2675350fa19143af881080b67cd5

PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_GOST_COMPRESS_GOPROXY \
	CONFIG_GOST_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/ginuerzh/gost
GO_PKG_BUILD_PKG:=github.com/ginuerzh/gost/cmd/gost
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/gost
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GO Simple Tunnel
  URL:=https://github.com/ginuerzh/gost
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/gost/description
  A simple security tunnel written in Golang
endef

define Package/gost/config
config GOST_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config GOST_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_GOST_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_GOST_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/gost
endif
endef

define Package/gost/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gost $(1)/usr/bin/gost

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/gost.config $(1)/etc/config/gost
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/gost.init $(1)/etc/init.d/gost
endef

$(eval $(call GoBinPackage,gost))
$(eval $(call BuildPackage,gost))

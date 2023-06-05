# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gotop
PKG_VERSION:=4.2.0
PKG_RELEASE:=4

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/xxxserxxx/gotop/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=314dcfc4b0faa0bb735e5fa84b2406492bf94f7948af43e2b9d2982d69d542ed

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/xxxserxxx/gotop.git
PKG_SOURCE_VERSION:=7a8dcee301b57ac1550f062aa817348f88574fc5
PKG_MIRROR_HASH:=1ceadbeb8aaccf69c6d7ca347a1180cec57792d6625cecdfabfd71144527faba

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_GOTOP_COMPRESS_GOPROXY \
	CONFIG_GOTOP_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
# PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/xxxserxxx/gotop
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/gotop
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=A terminal based graphical activity monitor
  URL:=https://github.com/xxxserxxx/gotop
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/gotop/description
  Another terminal based graphical activity monitor.
endef

define Package/gotop/config
config GOTOP_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config GOTOP_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_GOTOP_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_GOTOP_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/gotop
endif
endef

$(eval $(call GoBinPackage,gotop))
$(eval $(call BuildPackage,gotop))

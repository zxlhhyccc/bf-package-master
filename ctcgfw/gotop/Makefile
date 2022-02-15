# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gotop
PKG_VERSION:=4.1.3
PKG_RELEASE:=1

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/xxxserxxx/gotop/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=314dcfc4b0faa0bb735e5fa84b2406492bf94f7948af43e2b9d2982d69d542ed

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/xxxserxxx/gotop.git
PKG_SOURCE_VERSION:=7d2656726e181968a8003607e1f0ab002706e443
PKG_MIRROR_HASH:=2966483ed3d0d4fb16bace1adad12e1a6276e1deec59f75521728abff9bf8b48

PKG_LICENSE:=MIT
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=CN_SZTL <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_GOTOP_COMPRESS_GOPROXY \
	CONFIG_GOTOP_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

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

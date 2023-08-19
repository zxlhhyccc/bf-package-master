# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=annie
PKG_BASE_VERSION:=0.19.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/iawia002/annie.git
PKG_SOURCE_DATE:=2023-08-14
PKG_SOURCE_VERSION:=de9bd35ae059e15e8e8ce607da19e982c12e1870
PKG_MIRROR_HASH:=cc2dc48f250a215a2bff9e26267350ec68adf458130ff4a770f5d98fbe5e84c4

PKG_VERSION:=$(PKG_BASE_VERSION)-$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_ANNIE_COMPRESS_GOPROXY \
	CONFIG_ANNIE_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
# PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/iawia002/annie
GO_PKG_BUILD_PKG:=$$(GO_PKG)
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/annie
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=A fast, simple and clean video downloader
  URL:=https://github.com/iawia002/annie
  DEPENDS:=$(GO_ARCH_DEPENDS) +ffmpeg
endef

define Package/annie/config
config ANNIE_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config ANNIE_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_ANNIE_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_ANNIE_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/annie
endif
endef

$(eval $(call GoBinPackage,annie))
$(eval $(call BuildPackage,annie))

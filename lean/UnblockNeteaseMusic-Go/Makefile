# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=UnblockNeteaseMusic-Go
PKG_VERSION:=0.2.13
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/cnsilvan/UnblockNeteaseMusic.git
PKG_SOURCE_VERSION:=92b59c95a36622b04d28ba6cfd68c0038ce1ac22
PKG_MIRROR_HASH:=5edace25ae9f19afd3b980e0cded4f798091357ac341be4ab833281203a03be6
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_UNBLOCKNETEASEMUSIC_GO_COMPRESS_GOPROXY \
	CONFIG_UNBLOCKNETEASEMUSIC_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
# PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/cnsilvan/UnblockNeteaseMusic
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/version.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/UnblockNeteaseMusic-Go
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=Revive Netease Cloud Music (Golang)
  URL:=https://github.com/cnsilvan/UnblockNeteaseMusic
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/UnblockNeteaseMusic-Go/config
config UNBLOCKNETEASEMUSIC_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config UNBLOCKNETEASEMUSIC_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_UNBLOCKNETEASEMUSIC_GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.io
endif

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/UpdateDependencies
	cd $(PKG_BUILD_DIR) && \
		go get -u && \
		go mod tidy
endef

define Build/Compile
	$(call Build/UpdateDependencies)
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_UNBLOCKNETEASEMUSIC_GO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/UnblockNeteaseMusic
endif
endef

define Package/UnblockNeteaseMusic-Go/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/usr/share/UnblockNeteaseMusicGo
	$(CP) ./files/* $(1)/usr/share/UnblockNeteaseMusicGo/
endef

$(eval $(call GoBinPackage,UnblockNeteaseMusic-Go))
$(eval $(call BuildPackage,UnblockNeteaseMusic-Go))

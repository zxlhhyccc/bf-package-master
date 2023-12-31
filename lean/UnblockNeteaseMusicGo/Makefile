# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=UnblockNeteaseMusicGo
PKG_VERSION:=0.2.13
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cnsilvan/UnblockNeteaseMusic.git
PKG_SOURCE_VERSION:=92b59c95a36622b04d28ba6cfd68c0038ce1ac22
PKG_MIRROR_HASH:=208579ac3eb1a88903b98e0a4185d17b27a67acc52227c76df7c1a2ee44cfa2f
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Silvan <cnsilvan@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_UNBLOCKNETEASEMUSICGO_COMPRESS_GOPROXY \
	CONFIG_UNBLOCKNETEASEMUSICGO_COMPRESS_UPX

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

define Package/$(PKG_NAME)/config
config UNBLOCKNETEASEMUSICGO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config UNBLOCKNETEASEMUSICGO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n

endef

ifeq ($(CONFIG_UNBLOCKNETEASEMUSICGO_INCLUDE_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.io
#export GOPROXY=https://mirrors.aliyun.com/goproxy/
endif

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Revive Netease Cloud Music (Golang)
	SUBMENU:=NeteaseMusic
	URL:=https://github.com/cnsilvan/UnblockNeteaseMusic
	DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/$(PKG_NAME)/description
Revive Netease Cloud Music (Golang)
endef

#define Build/Prepare
#	tar -xvf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_BUILD_DIR) --strip-components 1
#endef

define Build/Configure
  
endef

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/UpdateDependencies
	cd $(PKG_BUILD_DIR) && \
		go get -u && \
		go mod tidy
endef

define Build/Compile
	$(eval GO_PKG_BUILD_PKG:=$(GO_PKG))
	$(call Build/UpdateDependencies)
	$(call GoPackage/Build/Configure)
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_UNBLOCKNETEASEMUSICGO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/UnblockNeteaseMusic
endif
	chmod +wx $(GO_PKG_BUILD_BIN_DIR)/UnblockNeteaseMusic
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/UnblockNeteaseMusic $(1)/usr/bin/UnblockNeteaseMusic
	$(INSTALL_DIR) $(1)/usr/share/UnblockNeteaseMusicGo
	$(CP) ./files/* $(1)/usr/share/UnblockNeteaseMusicGo/
endef
$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))

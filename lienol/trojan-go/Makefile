# Copyright (C) 2020 Lienol
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=trojan-go
PKG_VERSION:=0.8.3.1
PKG_RELEASE:=1

#PKG_SOURCE_PROTO:=git
#PKG_SOURCE_URL:=https://github.com/p4gefau1t/trojan-go.git
#PKG_SOURCE_VERSION:=8d3ed140c2046e1d1ee688582b51e87773592d56
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_MIRROR_HASH:=14bed36cafb19e6cd399118c74fda9cc36391831312fc22828b05670107a285a

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/frainzy1477/trojan-go.git
PKG_SOURCE_VERSION:=0f87d4fee3204f19363206a33308c16fd1ef357c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_MIRROR_HASH:=e8991f7c2ae6226ba955138fa7ac9b97a305656014b4de4aab9c24e3cf6a7b90

PKG_CONFIG_DEPENDS:= \
	CONFIG_TROJAN_GO_COMPRESS_GOPROXY \
	CONFIG_TROJAN_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

#GO_PKG:=github.com/p4gefau1t/trojan-go
GO_PKG:=github.com/frainzy1477/trojan-go
GO_PKG_BUILD_PKG:=$$(GO_PKG)

GO_PKG_TAGS:=full
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/constant.Version=$(PKG_VERSION) \
	$(GO_PKG)/constant.Commit=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	DEPENDS:=$$(GO_ARCH_DEPENDS)
	TITLE:=An unidentifiable mechanism that helps you bypass GFW. It's compatible with original trojan with experimental features.
	URL:=https://github.com/p4gefau1t/trojan-go
endef

define Package/$(PKG_NAME)/config

menu "Configuration"
	depends on PACKAGE_$(PKG_NAME)

config TROJAN_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config TROJAN_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y

endmenu

endef

ifeq ($(CONFIG_TROJAN_GO_COMPRESS_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.io
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_TROJAN_GO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(PKG_NAME)
endif
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))

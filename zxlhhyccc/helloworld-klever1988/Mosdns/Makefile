# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=Mosdns
PKG_VERSION:=3.1.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=Mosdns-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/IrineSistiana/mosdns.git
PKG_SOURCE_VERSION:=b082b79d3c606f8aa5114d114f3bfda8cc8a268d
PKG_MIRROR_HASH:=cff6dc61a20ccc8936df20f21a9cfe276eefb3ac6cfb2772c0857098a8dd1031

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_Mosdns_COMPRESS_GOPROXY \
	CONFIG_Mosdns_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/IrineSistiana/mosdns
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/Mosdns
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A plug-in DNS forwarder/splitter
  URL:=https://github.com/IrineSistiana/mosdns
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/Mosdns/config
config Mosdns_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config Mosdns_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_Mosdns_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_Mosdns_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/mosdns
endif
endef

define Package/Mosdns/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/mosdns
	$(INSTALL_DATA) ./files/config.yaml $(1)/etc/mosdns/config.yaml
endef

$(eval $(call GoBinPackage,Mosdns))
$(eval $(call BuildPackage,Mosdns))

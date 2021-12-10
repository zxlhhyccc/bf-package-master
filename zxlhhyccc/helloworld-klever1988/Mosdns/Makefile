# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=Mosdns
PKG_VERSION:=2.1.2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=Mosdns-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/IrineSistiana/mosdns.git
PKG_SOURCE_VERSION:=293b0185a6c349c03f339f5f8f1cdba1da740907
PKG_MIRROR_HASH:=a12240434c2f0b38b00252f22f7fb792ca7e6506c63ad570c7e58f7855e04d35

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_MOSDNS_COMPRESS_GOPROXY \
	CONFIG_MOSDNS_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/IrineSistiana/mosdns
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/Mosdns/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A plug-in DNS forwarder/splitter
  URL:=https://github.com/IrineSistiana/mosdns
endef

define Package/Mosdns
  $(call Package/Mosdns/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/Mosdns-geodata
  $(call Package/Mosdns/Default)
  TITLE+= (geodata resources)
  DEPENDS:=Mosdns
endef

define Package/Mosdns/config
config MOSDNS_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config MOSDNS_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_MOSDNS_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

GEOIP_VER:=202112090049
GEOIP_FILE:=geoip.dat.$(GEOIP_VER)

define Download/geoip
  URL:=https://github.com/Loyalsoldier/geoip/releases/latest/download
  URL_FILE:=geoip-only-cn-private.dat
  FILE:=$(GEOIP_FILE)
  HASH:=2fe4fe63e142c55d84b9e82be2c8ecc054e557ea9838571544d1714987bd4876
endef

GEOSITE_VER:=202112092210
# GEOSITE_FILE:=dlc.dat.$(GEOSITE_VER)
GEOSITE_FILE:=geosite.dat.$(GEOSITE_VER)

define Download/geosite
  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download
  URL_FILE:=geosite.dat
  FILE:=$(GEOSITE_FILE)
  HASH:=9e82699cbd2e8667dd3c95c5e6452599779db24b2c6fb410beb31e97814eec08
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifneq ($(CONFIG_PACKAGE_Mosdns-geodata),)
	$(call Download,geoip)
	$(call Download,geosite)
endif
endef

GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_MOSDNS_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/mosdns
endif
endef

define Package/Mosdns/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/mosdns
	$(INSTALL_DATA) ./files/config.yaml $(1)/etc/mosdns/config.yaml
endef

define Package/Mosdns-geodata/install
	$(INSTALL_DIR) $(1)/etc/mosdns
	$(INSTALL_DATA) $(DL_DIR)/$(GEOIP_FILE) $(1)/etc/mosdns/geoip.dat
	$(INSTALL_DATA) $(DL_DIR)/$(GEOSITE_FILE) $(1)/etc/mosdns/geosite.dat
endef

$(eval $(call GoBinPackage,Mosdns))
$(eval $(call BuildPackage,Mosdns))
$(eval $(call BuildPackage,Mosdns-geodata))

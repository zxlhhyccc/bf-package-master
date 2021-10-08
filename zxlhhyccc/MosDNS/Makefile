# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=MosDNS
PKG_VERSION:=2.0.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=MosDNS-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/IrineSistiana/mosdns.git
PKG_SOURCE_VERSION:=5048c7787f605ed9fcf5110415a9ca5014272715
PKG_MIRROR_HASH:=3793596ac21f3c7bade3f0e0caede803264272cf7c6df742add943faf32efe52

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

define Package/MosDNS/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=A plug-in DNS forwarder/splitter
  URL:=https://github.com/IrineSistiana/mosdns
endef

define Package/MosDNS
  $(call Package/MosDNS/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/MosDNS-geodata
  $(call Package/MosDNS/Default)
  TITLE+= (geodata resources)
  DEPENDS:=MosDNS
endef

define Package/MosDNS/config
config MOSDNS_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config MOSDNS_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

ifeq ($(CONFIG_MOSDNS_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

GEOIP_VER:=202110040733
GEOIP_FILE:=geoip.dat.$(GEOIP_VER)

define Download/geoip
  URL:=https://github.com/v2fly/geoip/releases/download/$(GEOIP_VER)/
  URL_FILE:=geoip.dat
  FILE:=$(GEOIP_FILE)
  HASH:=00621e6d6de481e48f232457afe99d338e2f63bc0c49c74068396da0251d5fb4
endef

GEOSITE_VER:=20211005043132
GEOSITE_FILE:=dlc.dat.$(GEOSITE_VER)

define Download/geosite
  URL:=https://github.com/v2fly/domain-list-community/releases/download/$(GEOSITE_VER)/
  URL_FILE:=dlc.dat
  FILE:=$(GEOSITE_FILE)
  HASH:=71bb8ae544b7995c11ac02e5461c8b6317479fa7db2b3065576b0feee669d3a3
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifneq ($(CONFIG_PACKAGE_MosDNS-geodata),)
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

define Package/MosDNS/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

define Package/MosDNS-geodata/install
	$(INSTALL_DIR) $(1)/etc/mosdns
	$(INSTALL_DATA) $(DL_DIR)/$(GEOIP_FILE) $(1)/etc/mosdns/geoip.dat
	$(INSTALL_DATA) $(DL_DIR)/$(GEOSITE_FILE) $(1)/etc/mosdns/geosite.dat
endef

$(eval $(call GoBinPackage,MosDNS))
$(eval $(call BuildPackage,MosDNS))
$(eval $(call BuildPackage,MosDNS-geodata))

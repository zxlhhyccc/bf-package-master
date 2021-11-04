# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=MosDNS
PKG_VERSION:=2.1.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=MosDNS-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/IrineSistiana/mosdns.git
PKG_SOURCE_VERSION:=546b56f1b589c155b84ec6a09ac6e22e301773fb
PKG_MIRROR_HASH:=bd8e30799429deb7017c7f715a452e97ffb11cb9213688df585f9dc3f2c4d1ee

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
	depends on !mips64
	default y if mips||mipsel
endef

ifeq ($(CONFIG_MOSDNS_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

GEOIP_VER:=202111032209
GEOIP_FILE:=geoip.dat.$(GEOIP_VER)

define Download/geoip
#  URL:=https://github.com/v2fly/geoip/releases/download/$(GEOIP_VER)/
#  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$(GEOIP_VER)/
  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download
  URL_FILE:=geoip.dat
  FILE:=$(GEOIP_FILE)
  HASH:=skip
endef

GEOSITE_VER:=202111032209
#GEOSITE_FILE:=dlc.dat.$(GEOSITE_VER)
GEOSITE_FILE:=geosite.dat.$(GEOSITE_VER)

define Download/geosite
#  URL:=https://github.com/v2fly/domain-list-community/releases/download/$(GEOSITE_VER)/
#  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$(GEOIP_VER)/
  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download
#  URL_FILE:=dlc.dat
  URL_FILE:=geosite.dat
  FILE:=$(GEOSITE_FILE)
  HASH:=skip
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

# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/luci-app-ddnsgo 
# 
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lucky
PKG_VERSION:=1.5.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/gdy666/lucky.git
PKG_SOURCE_VERSION:=b20df80c5085f8db380d4d8f3078fbe0b0f8489a
PKG_MIRROR_HASH:=03111d4a234a9526fa99f2f480b6afc8ad0e03c2600796b694e63de5aaf3bef8

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=herboy2008 <herboy2008@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_LUCKY_COMPRESS_GOPROXY \
	CONFIG_LUCKY_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/gdy666/lucky
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/lucky
  TITLE:=Lucky dynamic domain name ddns-go service, socat,frp  
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +libc +libpthread
  URL:=https://github.com/gdy666/lucky.git
endef

define Package/$(PKG_NAME)/description
  Main functions of Lucky: dynamic domain name ddns-go service, socat,frp 
endef

define Package/$(PKG_NAME)/config
config LUCKY_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config LUCKY_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_LUCKY_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	[ -f /etc/uci-defaults/luci-lucky ] && /etc/uci-defaults/luci-lucky && rm -f /etc/uci-defaults/luci-lucky
fi
endef

define Build/Compile
( \
  pushd $(PKG_BUILD_DIR) ; \
  go build -v -tags "adminweb nomsgpack" -ldflags="-s -w" ; \
  popd ; \
)
ifneq ($(CONFIG_LUCKY_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/lucky
endif
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/etc/init.d $(1)/etc/uci-defaults $(1)/etc/lucky
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/lucky $(1)/usr/bin/lucky
	$(INSTALL_BIN) ./files/lucky.init $(1)/etc/init.d/lucky
	$(INSTALL_BIN) ./files/luci-lucky.uci-default $(1)/etc/uci-defaults/luci-lucky
	$(INSTALL_DATA) ./files/lucky-default.conf $(1)/etc/lucky/lucky-default.conf
endef

$(eval $(call GoBinPackage,lucky))
$(eval $(call BuildPackage,lucky))

#
# Copyright (C) 2019 Xingwang Liao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=kcptun
PKG_VERSION:=20210103
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/xtaci/kcptun.git
PKG_MIRROR_HASH:=0c7e12ba26ba55fdd2c667449f64e5e3dcfca169ab8b8695941f8c5a8ebd69df
PKG_SOURCE_VERSION:=07ad03fecf37885282038e27360d2eff86007553

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_KCPTUN_CLIENT_CORE_COMPRESS_UPX \
	CONFIG_KCPTUN_SERVER_CORE_COMPRESS_UPX

GO_PKG:=github.com/xtaci/kcptun

GO_PKG_LDFLAGS:=-s -w -X 'main.VERSION=$(PKG_VERSION)-$(PKG_RELEASE) for OpenWrt'

# Can't use GO_PKG_LDFLAGS_X to define X args with space

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/kcptun/template
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Simple UDP Tunnel Based On KCP client server
  DEPENDS:=$(GO_ARCH_DEPENDS)
  URL:=https://github.com/xtaci/kcptun
  SUBMENU:=Web Servers/Proxies
endef

define Package/kcptun-client
  $(call Package/kcptun/template)
  TITLE+= (client)
endef

define Package/kcptun-server
  $(call Package/kcptun/template)
  TITLE+= (server)
endef

define Package/kcptun/description
  A Stable & Secure Tunnel Based On KCP with N:M Multiplexing.
endef

Package/kcptun-client/description = $(Package/kcptun/description/template)
Package/kcptun-server/description = $(Package/kcptun/description/template)

define Package/kcptun-client/config
config KCPTUN_CLIENT_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

define Package/kcptun-server/config
config KCPTUN_SERVER_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_KCPTUN_CLIENT_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/client
endif
ifeq ($(CONFIG_KCPTUN_SERVER_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/server
endif
endef

define Package/kcptun/install/template
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin/kcptun-$(2)
endef

Package/kcptun-client/install = $(call Package/kcptun/install/template,$(1),client)
Package/kcptun-server/install = $(call Package/kcptun/install/template,$(1),server)

$(eval $(call GoBinPackage,kcptun-client))
$(eval $(call GoBinPackage,kcptun-server))
$(eval $(call BuildPackage,kcptun-client))
$(eval $(call BuildPackage,kcptun-server))

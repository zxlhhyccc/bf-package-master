#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.38.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fatedier/frp.git
PKG_SOURCE_VERSION:=05b1ace21fc87d96e330971998859404a65ba572
PKG_MIRROR_HASH:=3c4adfca6ef17f6cbf5fd4cebdf4df0afb5568f342449779686f31a87b562e04

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_FRPC_COMPRESS_UPX \
	CONFIG_FRPS_COMPRESS_UPX

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/...

GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/frp/template
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A fast reverse proxy FRPC FRPS
  DEPENDS:=$(GO_ARCH_DEPENDS)
  URL:=https://github.com/fatedier/frp
  SUBMENU:=Web Servers/Proxies
endef

define Package/frpc
  $(call Package/frp/template)
  TITLE+= (client)
endef

define Package/frps
  $(call Package/frp/template)
  TITLE+= (server)
endef

define Package/frp/description
  frp is a fast reverse proxy to help you expose a local server behind a NAT or firewall
  to the internet. As of now, it supports tcp & udp, as well as http and https protocols,
  where requests can be forwarded to internal services by domain name.
endef

Package/frpc/description = $(Package/frp/description/template)
Package/frps/description = $(Package/frp/description/template)

define Package/frpc/config
config FRPC_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default y if mips||mipsel
endef

define Package/frps/config
config FRPS_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default y if mips||mipsel
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_FRPC_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/frpc
endif
ifeq ($(CONFIG_FRPS_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/frps
endif
endef

define Package/frp/install/template
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin/$(2)
endef

Package/frpc/install = $(call Package/frp/install/template,$(1),frpc)
Package/frps/install = $(call Package/frp/install/template,$(1),frps)

$(eval $(call GoBinPackage,frpc))
$(eval $(call GoBinPackage,frps))
$(eval $(call BuildPackage,frpc))
$(eval $(call BuildPackage,frps))

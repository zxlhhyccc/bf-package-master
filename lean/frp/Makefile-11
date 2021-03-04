#
# Copyright (C) 2019 Xingwang Liao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.35.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fatedier/frp.git
PKG_MIRROR_HASH:=042831f958c432f137b5f8928208c82cfb2dc0fb26aaa0ddf91d5fa6414629a8
PKG_SOURCE_VERSION:=3bf1eb85659ee49aff28dfb70e537b1f54b84365

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS := \
	CONFIG_FRPC_COMPRESS_UPX \
	CONFIG_FRPS_COMPRESS_UPX

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/...

GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define frp/templates
  define Package/$(1)
    TITLE:=A fast reverse proxy ($(1))
    URL:=https://github.com/fatedier/frp
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    DEPENDS:=$$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
  frp is a fast reverse proxy to help you expose a local server behind a NAT or firewall
  to the internet. As of now, it supports tcp & udp, as well as http and https protocols,
  where requests can be forwarded to internal services by domain name.

  This package contains the $(1).
  endef

  define Package/frpc/config
	config FRPC_COMPRESS_UPX
		bool "Compress executable files with UPX"
		default y
  endef

  define Package/frps/config
	config FRPS_COMPRESS_UPX
		bool "Compress executable files with UPX"
		default y
  endef

  define Build/Compile
	$(call GoPackage/Build/Compile)
  ifeq ($(CONFIG_FRPC_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/frpc
  endif
  ifeq ($(CONFIG_FRPS_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/frps
  endif
  endef

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef
endef

FRP_COMPONENTS:=frpc frps

$(foreach component,$(FRP_COMPONENTS), \
  $(eval $(call frp/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)

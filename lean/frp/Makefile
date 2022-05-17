#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.42.0
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fatedier/frp.git
PKG_SOURCE_VERSION:=eb1e19a8212061e56a43ce798a231cd64cce989d
PKG_MIRROR_HASH:=ea0f763e4a21a3d663374f4d4b3537f7cf4205eccf36e96fa8b4e55a3c1aa235

PKG_CONFIG_DEPENDS:= \
	CONFIG_FRP_$(1)_COMPRESS_GOPROXY \
	CONFIG_FRP_$(1)_COMPRESS_UPX

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/...

GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define frp/templates
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=A fast reverse proxy ($(1))
    DEPENDS:=$$(GO_ARCH_DEPENDS)
    URL:=https://github.com/fatedier/frp
  endef

  define Package/$(1)/description
  frp is a fast reverse proxy to help you expose a local server behind a NAT or firewall
  to the internet. As of now, it supports tcp & udp, as well as http and https protocols,
  where requests can be forwarded to internal services by domain name.

  This package contains the $(1).
  endef

  define Package/$(1)/config
    config FRP_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config FRP_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_FRP_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  endef
endef

FRP_COMPONENTS:=frpc frps

define Build/Compile
	$(call GoPackage/Build/Compile)
$(foreach component,$(FRP_COMPONENTS),
  ifneq ($(CONFIG_FRP_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(component)
  endif
)
endef

$(foreach component,$(FRP_COMPONENTS), \
  $(eval $(call frp/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)

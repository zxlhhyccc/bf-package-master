# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=nps
PKG_VERSION:=0.26.28
PKG_RELEASE:=1

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/ehang-io/nps/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=1b2fe9d251f55105d65027a1cee464f65d2f6ab3bd4a20e4655e5135db68aee7

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://github.com/ehang-io/nps.git
PKG_SOURCE_URL:=https://github.com/yisier/nps.git
PKG_SOURCE_VERSION:=b821409b04235d31dc4fb99829da8df3c836a0d2
PKG_MIRROR_HASH:=553f607b2cef3dcae296178e0176ef1748a2da1f19d496ac6c1762229cad704b

PKG_CONFIG_DEPENDS:= \
	CONFIG_NPS_$(1)_PROVIDE_NPSVIP \
	CONFIG_NPS_$(1)_COMPRESS_GOPROXY \
	CONFIG_NPS_$(1)_COMPRESS_UPX

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINTER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=ehang.io/nps
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/...
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define nps/templates
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=A intranet penetration proxy server ($(1))
    DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
    URL:=https://ehang-io.github.io/nps
    PROVIDES:=$(1)vip
  endef

  define Package/$(1)/description
  NPS is a lightweight, high-performance, powerful intranet penetration proxy server,
  with a powerful web management terminal.

  This package contains the $(1).
  endef

  define Package/$(1)/config
    config NPS_$(1)_PROVIDE_NPSVIP
      bool "Provide NPSvip binary using NPS"
      default n 
 
    config NPS_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config NPS_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_NPS_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/$(1)/install
	$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/
  ifneq ($(CONFIG_NPS_$(1)_PROVIDE_NPSVIP),)
	$$(LN) npc $$(1)/usr/bin/npsvip
  endif
  endef
endef

# define Build/UpdateDependencies
#	cd $(PKG_BUILD_DIR) && \
#		go mod tidy
# endef

NPS_COMPONENTS:=npc nps

define Build/Compile
	$(call Build/UpdateDependencies)
	$(call GoPackage/Build/Compile)
$(foreach component,$(NPS_COMPONENTS),
  ifneq ($(CONFIG_NPS_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(component)
  endif
)
endef

$(foreach component,$(NPS_COMPONENTS), \
  $(eval $(call nps/templates,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)

# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=sagernet-core
BASE_VERSION:=5.0.14
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/SagerNet/v2ray-core.git
PKG_SOURCE_DATE:=2022-06-09
PKG_SOURCE_VERSION:=ad0e3fb4854c64abc0ce8a5cb9f3c661559085f0
PKG_MIRROR_HASH:=6bfa351d9467f892e5683d54b8fd20dbbe8daf89bedf4daae4c36fee887cbfd2
PKG_VERSION:=$(BASE_VERSION)-$(PKG_SOURCE_DATE)-$(call version_abbrev,$(PKG_SOURCE_VERSION))

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_SAGERNET_CORE_PROVIDE_XRAY \
	CONFIG_SAGERNET_CORE_COMPRESS_GOPROXY \
	CONFIG_SAGERNET_CORE_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/v2fly/v2ray-core/v5
GO_PKG_BUILD_PKG:=$(GO_PKG)/main
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG).build=OpenWrt \
	$(GO_PKG).version=$(BASE_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/sagernet/template
  TITLE:=An enhanced v2ray edition for SagerNet
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  URL:=https://sagernet.org
endef

define Package/sagernet-core
  $(call Package/sagernet/template)
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  CONFLICTS:=v2ray-core xray-core
endef

define Package/sagernet-example
  $(call Package/sagernet/template)
  TITLE+= (example configs)
  DEPENDS:=sagernet-core
  CONFLICTS:=v2ray-example
  PKGARCH:=all
endef

define Package/sagernet-extra
  $(call Package/sagernet/template)
  TITLE+= (extra resources)
  DEPENDS:=sagernet-core
  CONFLICTS:=v2ray-extra
  PKGARCH:=all
endef

define Package/sagernet/description
  Project V is a set of network tools that help you to build your own computer network.
  It secures your network connections and thus protects your privacy.
endef

define Package/sagernet-core/description
  $(call Package/sagernet/description)

  This is a v2ray-core fork for SagerNet.
endef

define Package/sagernet-example/description
  $(call Package/sagernet/description)

  This includes example configuration files for sagernet-core.
endef

define Package/sagernet-extra/description
  $(call Package/sagernet/description)

  This includes extra resources for sagernet-core.
endef

define Package/sagernet-core/conffiles
/etc/config/v2ray
/etc/v2ray/
endef

define Package/sagernet-core/config
menu "sagernet-core Configuration"
	depends on PACKAGE_sagernet-core

config SAGERNET_CORE_PROVIDE_XRAY
      bool "Provide Xray binary using Sagernet-core"
      default n 

config SAGERNET_CORE_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config SAGERNET_CORE_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endmenu
endef

ifneq ($(CONFIG_SAGERNET_CORE_COMPRESS_GOPROXY),)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_SAGERNET_CORE_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/main
endif
endef

define Package/sagernet-core/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/main $(1)/usr/bin/v2ray
ifneq ($(CONFIG_SAGERNET_CORE_PROVIDE_XRAY),)
	$(LN) v2ray $(1)/usr/bin/xray
endif
	$(INSTALL_DIR) $(1)/etc/v2ray/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/release/config/config.json $(1)/etc/v2ray/

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/v2ray.conf $(1)/etc/config/v2ray
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/v2ray.init $(1)/etc/init.d/v2ray
endef

define Package/sagernet-example/install
	$(INSTALL_DIR) $(1)/etc/v2ray/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/release/config/vpoint_socks_vmess.json $(1)/etc/v2ray/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/release/config/vpoint_vmess_freedom.json $(1)/etc/v2ray/
endef

define Package/sagernet-extra/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray/
	$(CP) $(PKG_BUILD_DIR)/release/extra/* $(1)/usr/share/v2ray/
endef

$(eval $(call BuildPackage,sagernet-core))
$(eval $(call BuildPackage,sagernet-example))
$(eval $(call BuildPackage,sagernet-extra))

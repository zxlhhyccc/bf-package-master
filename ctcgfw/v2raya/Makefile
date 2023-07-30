# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=v2rayA
PKG_VERSION:=2.0.5
PKG_RELEASE:=1

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/v2rayA/v2rayA/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=5bb02d178cdc95de1facdd214392d753be128bef522ae7654ebdbc880b874f37
# PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/service

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/v2rayA/v2rayA.git
PKG_SOURCE_VERSION:=b41e22f2f9bdcb85353bbdf06f12f230bb96cfce
PKG_MIRROR_HASH:=38824039b4c330cc76a3160f0339b8af92f46f59127f07f9420555ddd099a8c0
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/service

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_V2RAYA_COMPRESS_GOPROXY \
	CONFIG_V2RAYA_COMPRESS_UPX \

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
# PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/v2rayA/v2rayA
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/conf.Version=$(PKG_VERSION) \
	$(GO_PKG)/core/iptables.TproxyNotSkipBr=true

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1)/.. $(TAR_OPTIONS)

define Package/v2raya
  TITLE:=A Linux web GUI client of Project V
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +ca-bundle \
    +PACKAGE_firewall4:kmod-nft-tproxy \
    +PACKAGE_firewall:iptables-mod-conntrack-extra \
    +PACKAGE_firewall:iptables-mod-extra \
    +PACKAGE_firewall:iptables-mod-filter \
    +PACKAGE_firewall:iptables-mod-tproxy \
    +PACKAGE_firewall:kmod-ipt-nat6 \
    +xray-core
ifneq ($(CONFIG_PACKAGE_firewall),)
  DEPENDS:=+IPV6:ip6tables

endif
  URL:=https://v2raya.org
endef

define Package/v2raya/description
  v2rayA is a V2Ray Linux client supporting global transparent proxy,
  compatible with SS, SSR, Trojan(trojan-go), PingTunnel protocols.
endef

define Package/v2raya/config
config V2RAYA_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config V2RAYA_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifneq ($(CONFIG_V2RAYA_COMPRESS_GOPROXY),)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.bj.bcebos.com
endif

define Package/v2raya/conffiles
/etc/v2raya/
/etc/config/v2raya
endef

WEB_FILE:=$(PKG_NAME)-web-$(PKG_VERSION).tar.gz
define Download/v2raya-web
	URL:=https://codeload.github.com/v2rayA/v2raya-web/tar.gz/v$(PKG_VERSION)?
	URL_FILE:=$(WEB_FILE)
	FILE:=$(WEB_FILE)
	HASH:=e0460ea4b251339258e037712dc7d7426e2929ce592becbd2182facaedbe7b81
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	( \
		mkdir -p $(PKG_BUILD_DIR)/server/router/web ; \
		gzip -dc $(DL_DIR)/$(WEB_FILE) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/server/router/web $(TAR_OPTIONS) ; \
	)
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_V2RAYA_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/v2rayA
endif
endef

define Package/v2raya/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/v2rayA $(1)/usr/bin/v2raya

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/v2raya.config $(1)/etc/config/v2raya
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/v2raya.init $(1)/etc/init.d/v2raya
endef

$(eval $(call Download,v2raya-web))
$(eval $(call GoBinPackage,v2raya))
$(eval $(call BuildPackage,v2raya))

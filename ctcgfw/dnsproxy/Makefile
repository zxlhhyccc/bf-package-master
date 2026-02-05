# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dnsproxy
PKG_VERSION:=0.78.2
PKG_RELEASE:=1

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/AdguardTeam/dnsproxy/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=151616e2562b9bc8de85725293b264e7769d84fe1cd462e74be6fdc8505b0cbb

PKG_SOURCE_PROTO:=git
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/AdguardTeam/dnsproxy.git
PKG_SOURCE_DATE:=2026-02-04
PKG_SOURCE_VERSION:=9067446f1781f62e8db10e74e3f9a54f259986a5
PKG_MIRROR_HASH:=3b7ddc7a28252001613ba0572b6ca3d531e4e14a43f0c89dbdcfa85c40a1d0b6

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_DNSPROXY_COMPRESS_GOPROXY \
	CONFIG_DNSPROXY_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/AdguardTeam/dnsproxy
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=$(GO_PKG)/internal/version.version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/dnsproxy/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support
  URL:=https://github.com/AdguardTeam/dnsproxy
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  USERID:=dnsproxy=411:dnsproxy=411
endef

define Package/dnsproxy/Default/description
  A simple DNS proxy server that supports all existing DNS protocols including
  DNS-over-TLS, DNS-over-HTTPS, DNSCrypt, and DNS-over-QUIC.Moreover, it can
  work as a DNS-over-HTTPS, DNS-over-TLS or DNS-over-QUIC server.
endef

define Package/dnsproxy
  $(call Package/dnsproxy/Default)
endef

define Package/dnsproxy-neo
  $(call Package/dnsproxy/Default)
endef

define Package/dnsproxy/description
  $(call Package/dnsproxy/Default/description)
endef

define Package/dnsproxy-neo/description
  $(call Package/dnsproxy/Default/description)
endef

define Package/dnsproxy/config
config DNSPROXY_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config DNSPROXY_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_DNSPROXY_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/dnsproxy/conffiles
/etc/config/dnsproxy
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_DNSPROXY_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/dnsproxy
endif
endef

define Package/dnsproxy/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/capabilities/
	$(INSTALL_DATA) $(CURDIR)/files/dnsproxy.json $(1)/etc/capabilities/dnsproxy.json
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/dnsproxy.config $(1)/etc/config/dnsproxy
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/dnsproxy.init $(1)/etc/init.d/dnsproxy
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_BIN) $(CURDIR)/files/dnsproxy.defaults $(1)/etc/uci-defaults/80-dnsproxy-migration
	$(INSTALL_DIR) $(1)/etc/sysctl.d/
	$(INSTALL_CONF) ./files/dnsproxy.sysctl $(1)/etc/sysctl.d/50-dnsproxy.conf
endef

define Package/dnsproxy-neo/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

$(eval $(call GoBinPackage,dnsproxy))
$(eval $(call BuildPackage,dnsproxy))
$(eval $(call BuildPackage,dnsproxy-neo))

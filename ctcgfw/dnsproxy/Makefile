# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dnsproxy
PKG_VERSION:=0.71.0
PKG_RELEASE:=1

# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/AdguardTeam/dnsproxy/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=151616e2562b9bc8de85725293b264e7769d84fe1cd462e74be6fdc8505b0cbb

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/AdguardTeam/dnsproxy.git
PKG_SOURCE_DATE:=2024-04-26
PKG_SOURCE_VERSION:=e35720fca466dd5b5f0110eef15cf89b4040f8f1
PKG_MIRROR_HASH:=6e2314aa03b8ebbefee337d1009aaa255d7a01074558b3168189f8a55e507a81

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

define Package/dnsproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Simple DNS proxy with DoH, DoT, DoQ and DNSCrypt support
  URL:=https://github.com/AdguardTeam/dnsproxy
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
  USERID:=dnsproxy=411:dnsproxy=411
endef

define Package/dnsproxy/description
  A simple DNS proxy server that supports all existing DNS protocols including
  DNS-over-TLS, DNS-over-HTTPS, DNSCrypt, and DNS-over-QUIC.Moreover, it can
  work as a DNS-over-HTTPS, DNS-over-TLS or DNS-over-QUIC server.
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

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/dnsproxy.config $(1)/etc/config/dnsproxy
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/dnsproxy.init $(1)/etc/init.d/dnsproxy
	$(INSTALL_DIR) $(1)/etc/uci-defaults/
	$(INSTALL_BIN) $(CURDIR)/files/dnsproxy.defaults $(1)/etc/uci-defaults/80-dnsproxy-migration
endef

define Package/dnsproxy/conffiles
/etc/config/dnsproxy
endef

$(eval $(call GoBinPackage,dnsproxy))
$(eval $(call BuildPackage,dnsproxy))

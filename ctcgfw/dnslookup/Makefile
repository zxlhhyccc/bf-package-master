# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dnslookup
PKG_VERSION:=1.10.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ameshkov/dnslookup/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=6001fa5b54ba3a1b29f68eed4d12b026a1b716b1578342621f398fd4d569d199

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_DNSLOOKUP_COMPRESS_GOPROXY \
	CONFIG_DNSLOOKUP_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/ameshkov/dnslookup
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.VersionString=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/dnslookup/config
config DNSLOOKUP_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config DNSLOOKUP_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_DNSLOOKUP_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/dnslookup
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Simple command line utility to make DNS lookups to the specified server
  URL:=https://github.com/ameshkov/dnslookup
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/dnslookup/description
  Simple command line utility to make DNS lookups.
  Supports all known DNS protocols: plain DNS, DoH, DoT, DoQ, DNSCrypt.
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_DNSLOOKUP_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/dnslookup
endif
endef

$(eval $(call GoBinPackage,dnslookup))
$(eval $(call BuildPackage,dnslookup))

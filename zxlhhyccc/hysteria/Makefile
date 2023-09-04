# Copyright (C) 2021 xiaorouji
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/apernet/hysteria/tar.gz/app/v$(PKG_VERSION)?
#PKG_HASH:=06f86cf466cbe08e7aaea68914263780ed4474cd73df9a591676779535d330d5
##PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-app-v$(PKG_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/apernet/hysteria.git
PKG_SOURCE_VERSION:=c7545cc870e5cc62a187ad03a083920e6bef049f
PKG_MIRROR_HASH:=b4fc3bbeea1d313532f7cafe1fe66ea429be08dc8a5932845a90c2282bb0a1d0

PKG_CONFIG_DEPENDS:= \
	CONFIG_HYSTERIA_COMPRESS_GOPROXY \
	CONFIG_HYSTERIA_COMPRESS_UPX

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
# PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/apernet/hysteria
GO_PKG_BUILD_PKG:=$(GO_PKG)/app
GO_PKG_LDFLAGS_X = \
	$(GO_PKG)/app/cmd.appVersion=v$(PKG_VERSION) \
	$(GO_PKG)/app/cmd.appType=release \
	$(GO_PKG)/app/cmd.appPlatform=$(GO_OS) \
	$(GO_PKG)/app/cmd.appArch=$(GO_ARCH)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Package/hysteria
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=A feature-packed network utility optimized for networks of poor quality
	DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
	URL:=https://github.com/apernet/hysteria
endef

define Package/hysteria/description
  Hysteria is a feature-packed network utility optimized for networks
  of poor quality (e.g. satellite connections, congested public Wi-Fi,
  connecting from China to servers abroad) powered by a custom version
  of QUIC protocol.
endef

define Package/hysteria/config

menu "Configuration"
	depends on PACKAGE_$(PKG_NAME)

config HYSTERIA_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config HYSTERIA_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n

endmenu

endef

ifeq ($(CONFIG_HYSTERIA_COMPRESS_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.io
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_HYSTERIA_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/app
endif
endef

define Package/hysteria/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/app $(1)/usr/bin/hysteria
endef

$(eval $(call GoBinPackage,hysteria))
$(eval $(call BuildPackage,hysteria))

# Copyright (C) 2021 xiaorouji
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hysteria
PKG_VERSION:=2.4.5
PKG_RELEASE:=1

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/apernet/hysteria/tar.gz/app/v$(PKG_VERSION)?
#PKG_HASH:=04e66404575ce680276aa485cacf42e6c488361e955c1ff89f0b2a070695fe3f
##PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-app-v$(PKG_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/apernet/hysteria.git
PKG_SOURCE_VERSION:=988b86ae5529bdac57cf0b8f7c73c5b923ec428b
PKG_MIRROR_HASH:=ba87e9ac67cbe4eafab4b2b3d7c9d89b057021659dc10cfaf2ab52feda0eb83e

PKG_CONFIG_DEPENDS:= \
	CONFIG_HYSTERIA_COMPRESS_GOPROXY \
	CONFIG_HYSTERIA_COMPRESS_UPX

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/apernet/hysteria
GO_PKG_BUILD_PKG:=$(GO_PKG)/app/v2
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X = \
	$(GO_PKG)/app/v2/cmd.appVersion=v$(PKG_VERSION) \
	$(GO_PKG)/app/v2/cmd.appType=release \
	$(GO_PKG)/app/v2/cmd.appPlatform=$(GO_OS) \
	$(GO_PKG)/app/v2/cmd.appArch=$(GO_ARCH)

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

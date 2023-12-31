#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v2dat
PKG_SOURCE_DATE:=2022-12-15
PKG_SOURCE_VERSION:=47b8ee51fb528e11e1a83453b7e767a18d20d1f7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_DATE).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/urlesistiana/v2dat/tar.gz/$(PKG_SOURCE_VERSION)?
PKG_HASH:=dca45a31006aca3dba5f543f6990ca755ffb2bde8e533cc2bbe6bac9ec12f157
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_SOURCE_VERSION)

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=sbwml <admin@cooluc.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_V2DAT_COMPRESS_GOPROXY \
	CONFIG_V2DAT_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1

GO_PKG:=github.com/urlesistiana/v2dat
GO_PKG_LDFLAGS:= -s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/v2dat/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=V2ray geo/ip data unpack tools
  URL:=https://github.com/urlesistiana/v2dat
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/v2dat
  $(call Package/v2dat/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/v2dat/config
config V2DAT_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config V2DAT_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_V2DAT_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Prepare
	$(call Build/Prepare/Default)
endef

GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0

define Build/UpdateDependencies
	cd $(PKG_BUILD_DIR) && \
		go get -u && \
		go mod tidy
endef

define Build/Compile
	$(call Build/UpdateDependencies)
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_V2DAT_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/v2dat
endif
endef

define Package/v2dat/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

$(eval $(call GoBinPackage,v2dat))
$(eval $(call BuildPackage,v2dat))

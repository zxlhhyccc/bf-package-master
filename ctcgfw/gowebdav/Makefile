# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=gowebdav
PKG_VERSION:=0.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/1715173329/gowebdav/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=9d899f41d22af969216c08f38bfc10ab4e55f7ab500eb98c17e81a23e2e26ffe

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_GOWEBDAV_COMPRESS_GOPROXY \
	CONFIG_GOWEBDAV_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/1715173329/gowebdav
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/gowebdav
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=A simple WebDav server written in Go
  URL:=https://github.com/1715173329/gowebdav
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/gowebdav/config
config GOWEBDAV_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config GOWEBDAV_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_GOWEBDAV_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/gowebdav/conffiles
/etc/config/gowebdav
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_GOWEBDAV_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/gowebdav
endif
endef

define Package/gowebdav/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/gowebdav.config $(1)/etc/config/gowebdav
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/gowebdav.init $(1)/etc/init.d/gowebdav
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/gowebdav-migrate-config.sh $(1)/etc/uci-defaults/90-gowebdav-migrate-config
endef

$(eval $(call GoBinPackage,gowebdav))
$(eval $(call BuildPackage,gowebdav))

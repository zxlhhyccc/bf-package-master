# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=aliyundrive-webdav
PKG_VERSION:=2.3.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/messense/aliyundrive-webdav.git
PKG_SOURCE_VERSION:=affeeda09a88c9fda18e82583cc02c275e4b932d
PKG_MIRROR_HASH:=042a455ccd117dc8acf5a5e47e42f2df4da1068a6686151e20769eaa43e08fd7

PKG_CONFIG_DEPENDS:= \
	CONFIG_ALIYUNDRIVE-WEBDAV_COMPRESS_GOPROXY \
	CONFIG_ALIYUNDRIVE-WEBDAV_COMPRESS_UPX

PKG_LICENSE:=MIT
PKG_MAINTAINER:=messense <messense@icloud.com>

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

RUST_PKG_FEATURES:=rustls-tls atomic64 native-tls native-tls-vendored

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/aliyundrive-webdav
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=WebDAV server for AliyunDrive
  URL:=https://github.com/messense/aliyundrive-webdav
  DEPENDS:=$$(RUST_ARCH_DEPENDS)
endef

define Package/aliyundrive-webdav/description
  WebDAV server for AliyunDrive.
endef

define Package/aliyundrive-webdav/config
    config ALIYUNDRIVE-WEBDAV_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config ALIYUNDRIVE-WEBDAV_COMPRESS_UPX
      bool "Compress executable files with UPX"
      depends on !mips64
      default n
endef

ifneq ($(CONFIG_ALIYUNDRIVE-WEBDAV_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
endif

define Package/aliyundrive-webdav/conffiles
/etc/config/aliyundrive-webdav
endef

define Build/Compile
	#$(call Build/Compile/Cargo,, smartdns)
	$(call Build/Compile/Cargo)
ifneq ($(CONFIG_ALIYUNDRIVE-WEBDAV_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/stripped/aliyundrive-webdav
	#$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_INSTALL_DIR)/bin/smartdns
  endif
endef

define Package/aliyundrive-webdav/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/stripped/aliyundrive-webdav $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/aliyundrive-webdav.init $(1)/etc/init.d/aliyundrive-webdav
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/aliyundrive-webdav.config $(1)/etc/config/aliyundrive-webdav
endef

$(eval $(call BuildPackage,aliyundrive-webdav))

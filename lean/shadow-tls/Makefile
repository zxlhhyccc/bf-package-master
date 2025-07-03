# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=shadow-tls
PKG_VERSION:=0.2.25
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ihciah/shadow-tls/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1d1d436734823ba0302de6e91883ed892ea710769c722a139990194ff5837224

PKG_CONFIG_DEPENDS:= \
	CONFIG_SHADOW-TLS_COMPRESS_GOPROXY \
	CONFIG_SHADOW-TLS_COMPRESS_UPX

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/shadow-tls
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=A proxy to expose real tls handshake to the firewall
    URL:=https://github.com/ihciah/shadow-tls
    DEPENDS:=@(aarch64||arm||x86_64)
    DEPENDS:=$$(RUST_ARCH_DEPENDS)
endef

define Package/shadow-tls/description
    A proxy to expose real tls handshake to the firewall.

    It works like trojan but it does not require signing certificate.
    The firewall will see real tls handshake with valid certificate
    that you choose.
endef

define Package/shadow-tls/config
    config SHADOW-TLS_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config SHADOW-TLS_COMPRESS_UPX
      bool "Compress executable files with UPX"
      depends on !mips64
      default n
endef

ifneq ($(CONFIG_SHADOW-TLS_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call Build/Compile/Cargo)
ifneq ($(CONFIG_SHADOW-TLS_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/shadow-tls
	#$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_INSTALL_DIR)/bin/shadow-tls
  endif
endef

define Package/shadow-tls/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/shadow-tls $(1)/usr/bin/shadow-tls
endef

$(eval $(call RustBinPackage,shadow-tls))
$(eval $(call BuildPackage,shadow-tls))

# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dns2socks-rust
PKG_VERSION:=0.2.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/tun2proxy/dns2socks/tar.gz/v$(PKG_VERSION)?
#PKG_HASH:=2a4414112eec8389a1215eeac09e3df951c762cd04a90ad31fb18eebac2eb3f2
PKG_SOURCE_URL:=https://github.com/tun2proxy/dns2socks.git
PKG_SOURCE_DATE:=2025-12-31
PKG_SOURCE_VERSION:=fe15b9a98b9e2e5614e35e220635ee9a7d9f1395
PKG_MIRROR_HASH:=75855762d96f3203b239005c126ec17a36f172c0a432f361304597a0b26941ab

PKG_CONFIG_DEPENDS:= \
	CONFIG_DNS2SOCKS_RUST_COMPRESS_GOPROXY \
	CONFIG_DNS2SOCKS_RUST_COMPRESS_UPX

PKG_MAINTAINER:=Zxlhhyccc <zxlhhyccc@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

#RUST_PKG:=dns2socks

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/dns2socks-rust
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=IP Addresses and Names
    TITLE:=DNS forwards to SOCKS5 server
    URL:=https://github.com/tun2proxy/dns2socks.git
    DEPENDS:=$$(RUST_ARCH_DEPENDS)
endef

define Package/dns2socks-rust/description
  This is a DNS server that forwards DNS requests to a SOCKS5 server.
endef

define Package/dns2socks-rust/config
    config DNS2SOCKS_RUST_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config DNS2SOCKS_RUST_COMPRESS_UPX
      bool "Compress executable files with UPX"
      depends on !mips64
      default n
endef

ifneq ($(CONFIG_DNS2SOCKS_RUST_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call Build/Compile/Cargo,,--all-features)
ifneq ($(CONFIG_DNS2SOCKS_RUST_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/dns2socks
  endif
endef

define Package/dns2socks-rust/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/dns2socks $(1)/usr/bin/dns2socks-rust
endef

$(eval $(call BuildPackage,dns2socks-rust))

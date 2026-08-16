# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=ipt2socks-rs
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fokx/ipt2socks-rs.git
PKG_SOURCE_VERSION:=5ec743ea93e88c5733614b6588f5eb0a25a3d5db
PKG_MIRROR_HASH:=fc13557af0aed05c953a5165ad17d35dc0071228ad6df72703151c1ebd0ddb01

PKG_CONFIG_DEPENDS:= \
	CONFIG_IPT2SOCKS-RS_COMPRESS_UPX

PKG_MAINTAINER:=Zxlhhyccc <zxlhhy@gmail.com>
PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/ipt2socks-rs
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Convert iptables/nftables to SOCKS5
  URL:=https://github.com/fokx/ipt2socks-rs.git
  DEPENDS:=$$(RUST_ARCH_DEPENDS)
endef

define Package/ipt2socks-rs/description
  A utility to convert iptables/nftables (REDIRECT/TPROXY) traffic to SOCKS5 (TCP/UDP).
endef

define Package/ipt2socks-rs/config
  config IPT2SOCKS-RS_COMPRESS_UPX
    bool "Compress executable with UPX"
    depends on !mips64
    default n
endef

define Build/Compile
	$(call Build/Compile/Cargo)
ifneq ($(CONFIG_IPT2SOCKS-RS_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best \
		$(PKG_INSTALL_DIR)/bin/ipt2socks-rs
endif
endef

define Package/ipt2socks-rs/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/bin/ipt2socks-rs \
		$(1)/usr/bin/ipt2socks
endef

$(eval $(call BuildPackage,ipt2socks-rs))

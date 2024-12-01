# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.21.2
PKG_RELEASE:=1


PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-rust.git
PKG_SOURCE_VERSION:=02c8451a093214eab0770f1409521836c6b13039
PKG_MIRROR_HASH:=db388237551c7b602cc06fbc10bd296d3ee8098f9525ff628f59cfbadb3af1b5
# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://codeload.github.com/shadowsocks/shadowsocks-rust/tar.gz/v$(PKG_VERSION)?
# PKG_HASH:=e854743ecef9ab3b371fdcb139e6f4452831b487d449c97c2129abbf4f51e863

PKG_CONFIG_DEPENDS:= \
	CONFIG_SHADOWSOCKS-RUST_$(1)_COMPRESS_GOPROXY \
	CONFIG_SHADOWSOCKS-RUST_$(1)_COMPRESS_UPX

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

RUST_PKG_FEATURES:=logging,local,server,manager,utility,hickory-dns,service,local-http,local-http-rustls,local-redir,local-tunnel,local-dns,local-fake-dns,local-tun,local-socks4,trust-dns,dns-over-tls,dns-over-https,dns-over-h3,stream-cipher,utility-url-outline,jemalloc,security-replay-attack-detect,multi-threaded,aead-cipher-2022,aead-cipher-2022-extra,security-replay-attack-detect

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/shadowsocks-rust/Default
  define Package/shadowsocks-rust-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=shadowsocks-rust $(1)
    URL:=https://shadowsocks.org/
    DEPENDS:=$$(RUST_ARCH_DEPENDS)
  endef

  define Package/shadowsocks-rust-$(1)/description
    Shadowsocks is a fast tunnel proxy that helps you bypass firewalls.

    This package contains the $(1).
  endef

  define Package/shadowsocks-rust-$(1)/config
    config SHADOWSOCKS-RUST_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config SHADOWSOCKS-RUST_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_SHADOWSOCKS-RUST_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/shadowsocks-rust-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/bin/$(1) $$(1)/usr/bin/
  endef
endef

SHADOWSOCKS_COMPONENTS:=sslocal ssserver ssurl ssmanager ssservice
define shadowsocks-rust/templates
  $(foreach component,$(SHADOWSOCKS_COMPONENTS),
    $(call Package/shadowsocks-rust/Default,$(component))
  )
endef
$(eval $(call shadowsocks-rust/templates))

define Build/Compile
	#$(call Build/Compile/Cargo,,--features local-redir)
	$(call Build/Compile/Cargo)
$(foreach component,$(SHADOWSOCKS_COMPONENTS),
  ifneq ($(CONFIG_SHADOWSOCKS-RUST_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_INSTALL_DIR)/bin/$(component)
  endif
  )
endef

$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
  $(eval $(call BuildPackage,shadowsocks-rust-$(component))) \
)

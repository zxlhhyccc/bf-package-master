# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns-rust
PKG_VERSION:=0.4.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/mokeyish/smartdns-rs.git
PKG_SOURCE_VERSION:=ed047e65c810729b53ae8a10b674cfe531ad6ed1
PKG_MIRROR_HASH:=cd15bee8701d3fa3f1df7e4cace6132be87ac748e8b8e1a349f4552c23e41f32

PKG_CONFIG_DEPENDS:= \
	CONFIG_SMARTDNS-RUST_COMPRESS_GOPROXY \
	CONFIG_SMARTDNS-RUST_COMPRESS_UPX

PKG_MAINTAINER:=Zxlhhyccc <zxlhhyccc@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/smartdns-rust/Default
  define Package/smartdns-rust
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=smartdns-rust server
    URL:=https://github.com/mokeyish/smartdns-rs.git
    DEPENDS:=$$(RUST_ARCH_DEPENDS)
  endef

  define Package/smartdns-rust/description
  A cross platform local DNS server (Dnsmasq like) written in rust to obtain the fastest website IP for the best Internet experience, supports DoT, DoH.
  endef

  define Package/smartdns-rust/config
    config SMARTDNS-RUST_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config SMARTDNS-RUST_COMPRESS_UPX
      bool "Compress executable files with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_SMARTDNS-RUST_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/smartdns-rust/install
	$$(INSTALL_DIR) $$(1)/usr/sbin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/bin/smartdns $$(1)/usr/sbin/

	$$(INSTALL_DIR) $$(1)/etc/init.d $$(1)/etc/smartdns $$(1)/etc/config
	$$(INSTALL_BIN) $(CURDIR)/conf/smartdns.init $$(1)/etc/init.d/smartdns
	$$(INSTALL_CONF) $(CURDIR)/conf/custom.conf $$(1)/etc/smartdns/custom.conf
	$$(INSTALL_CONF) $(CURDIR)/conf/smartdns.conf $$(1)/etc/config/smartdns
  endef
endef

define Package/smartdns-rust/conffiles
/etc/config/smartdns
/etc/smartdns/custom.conf
endef

define smartdns-rust/templates
  $(foreach smartdns,smartdns,
    $(call Package/smartdns-rust/Default,smartdns)
  )
endef
$(eval $(call smartdns-rust/templates))

define Build/Compile
	$(call Build/Compile/Cargo,, smartdns)
$(foreach smartdns,smartdns,
  ifneq ($(CONFIG_SMARTDNS-RUST_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_INSTALL_DIR)/bin/smartdns
  endif
  )
endef

$(foreach smartdns,smartdns, \
  $(eval $(call BuildPackage,smartdns-rust)) \
)

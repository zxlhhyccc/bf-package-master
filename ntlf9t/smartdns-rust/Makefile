# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns-rust
PKG_VERSION:=0.3.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/mokeyish/smartdns-rs.git
PKG_SOURCE_VERSION:=c8845a3abde88aafcb98f209dc53153dd9166b7d
PKG_MIRROR_HASH:=a80d2d1e9dc478575438155732a74b1f9af7331ee9c949d044a3ef387ed07c70

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
A cross platform local DNS server written in rust to obtain the fastest website IP for the best Internet experience, support DoT, DoH.
endef

define Package/smartdns-rust/install
	$$(INSTALL_DIR) $$(1)/usr/sbin
	$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/bin/smartdns $$(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/smartdns
	$(INSTALL_bin) $(CURDIR)/conf/smartdns.init $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(CURDIR)/conf/custom.conf $(1)/etc/smartdns/custom.conf
endef
endef

define smartdns-rust/templates
  $(foreach smartdns,smartdns,
    $(call Package/smartdns-rust/Default,$(smartdns))
  )
endef
$(eval $(call smartdns-rust/templates))

define Build/Compile
	$(call Build/Compile/Cargo,, smartdns)
endef

$(foreach smartdns,smartdns, \
  $(eval $(call BuildPackage,smartdns-rust)) \
)

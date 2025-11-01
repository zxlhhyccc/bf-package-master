# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=tuic
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/tuic-protocol/tuic.git
PKG_SOURCE_VERSION:=0acf4844c46e63b83eab3e58069fe8c060509974
PKG_MIRROR_HASH:=7da1a71b98df892b2d89d81cdeef96ab892fc936902afba2be757efacfa14c8d

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/tuic/Default
  define Package/tuic-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=Delicately-TUICed 0-RTT proxy protocol $(1)
    URL:=https://github.com/EAimTY/tuic
    DEPENDS:=@(aarch64||arm||x86_64)
  endef

  define Package/tuic-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/tuic-$(1) $$(1)/usr/bin/
  endef
endef

TUIC_COMPONENTS:=client server

define Build/Compile
	$(call BuildPackage/Build/Compile)
  $(foreach component,$(TUIC_COMPONENTS),
	( \
		pushd $(PKG_BUILD_DIR) ; \
		$(CARGO_PKG_CONFIG_VARS) \
		MAKEFLAGS="$(PKG_JOBS)" \
		TARGET_CFLAGS="$(filter-out -O%,$(TARGET_CFLAGS)) $(RUSTC_CFLAGS)" \
		cargo build -v --profile $(CARGO_PKG_PROFILE) ; \
		$(CARGO_PKG_ARGS) ; \
		popd ; \
	)
  )
endef

$(foreach component,$(TUIC_COMPONENTS), \
  $(eval $(call Package/tuic/Default,$(component))) \
  $(eval $(call GoBinPackage,tuic-$(component))) \
  $(eval $(call BuildPackage,tuic-$(component))) \
)

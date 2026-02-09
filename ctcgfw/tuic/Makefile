# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=tuic
PKG_VERSION:=1.6.8
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Itsusinn/tuic.git
PKG_SOURCE_VERSION:=86bc71586d797050284847d5ece9fe9d9d3529f3
PKG_MIRROR_HASH:=ef87bf7e75a928374929fb80c564c81a5ff2dad3023fe8d66616d57a734bf8c4

PKG_CONFIG_DEPENDS:= \
	CONFIG_TUIC_$(1)_COMPRESS_GOPROXY \
	CONFIG_TUIC_$(1)_COMPRESS_UPX

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
    TITLE:=TUIC proxy protocol $(1)
    URL:=https://github.com/EAimTY/tuic
    DEPENDS:=@(aarch64||arm||mips||mipsel||x86_64||i386||i686||riscv64||loongarch64)
  endef

  define Package/tuic-client/description
    Delicately-TUICed 0-RTT proxy protocol client.
  endef

  define Package/tuic-$(1)/config
    config TUIC_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config TUIC_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_TUIC_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/tuic-$(1)/install
	$(INSTALL_DIR) $$(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/tuic-$(1) $$(1)/usr/bin/
  endef
endef

TUIC_COMPONENTS:=client server

define Select/Features
$(strip \
  $(if $(findstring x86_64,$(RUSTC_TARGET_ARCH)),--features jemallocator) \
  $(if $(findstring aarch64,$(RUSTC_TARGET_ARCH)),--features jemallocator) \
  $(if $(or \
    $(findstring arm,$(RUSTC_TARGET_ARCH)), \
    $(findstring mips,$(RUSTC_TARGET_ARCH)), \
    $(findstring mipsel,$(RUSTC_TARGET_ARCH)), \
    $(findstring i686,$(RUSTC_TARGET_ARCH)), \
    $(findstring i386,$(RUSTC_TARGET_ARCH)), \
    $(findstring riscv64,$(RUSTC_TARGET_ARCH)), \
    $(findstring loongarch64,$(RUSTC_TARGET_ARCH)) \
  ),--no-default-features --features ring) \
)
endef

define Build/Compile
	( \
		pushd $(PKG_BUILD_DIR) ; \
		$(CARGO_PKG_CONFIG_VARS) \
		cargo build --release \
			--target $(RUSTC_TARGET_ARCH) \
			$(call Select/Features) ; \
		popd ; \
	)
$(foreach component,$(TUIC_COMPONENTS), 
  ifneq ($(CONFIG_TUIC_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/tuic-$(component)
  endif
)
endef

$(foreach component,$(TUIC_COMPONENTS), \
  $(eval $(call Package/tuic/Default,$(component))) \
  $(eval $(call RustBinPackage,tuic-$(component))) \
  $(eval $(call BuildPackage,tuic-$(component))) \
)

# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=tuic
PKG_VERSION:=1.7.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Itsusinn/tuic.git
PKG_SOURCE_VERSION:=819584272e8e63b1d4be31f75cdf641f84748d70
PKG_MIRROR_HASH:=ea3f54713715169e65a5766bd5856de8d8f75ba6c7ae6fde5703572cceedfa48

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
    DEPENDS:=@(aarch64||arm||x86_64||i686||riscv64||loongarch64)
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
CARGO_PACKAGES := $(foreach component,$(TUIC_COMPONENTS), \
                     $(if $(CONFIG_PACKAGE_tuic-$(component)), \
                         -p tuic-$(component)))

define Select/Features
$(strip \
  $(if $(or \
    $(findstring i686,$(RUSTC_TARGET_ARCH)), \
    $(findstring arm,$(RUSTC_TARGET_ARCH)), \
    $(findstring riscv64,$(RUSTC_TARGET_ARCH)), \
    $(findstring loongarch64,$(RUSTC_TARGET_ARCH)) \
  ),--no-default-features --features ring) \
  $(if $(or \
    $(findstring x86_64,$(RUSTC_TARGET_ARCH)), \
    $(findstring aarch64,$(RUSTC_TARGET_ARCH)) \
  ),--features jemallocator) \
)
endef

CARGO_ARGS += $(call Select/Features)
RUSTFLAGS += -C panic=abort

define Build/Compile
	( \
		pushd $(PKG_BUILD_DIR) ; \
		$(CARGO_PKG_CONFIG_VARS) \
		cargo build --release \
			--target $(RUSTC_TARGET_ARCH) \
			$(CARGO_PACKAGES) \
			$(CARGO_ARGS) ; \
		popd ; \
	)
	$(foreach component,$(TUIC_COMPONENTS), 
	  $(if $(CONFIG_PACKAGE_tuic-$(component)), \
	    $(if $(CONFIG_TUIC_$(component)_COMPRESS_UPX), \
	      $(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/target/$(RUSTC_TARGET_ARCH)/release/tuic-$(component) \
	    ) \
	  ) \
	)
endef

$(foreach component,$(TUIC_COMPONENTS), \
  $(eval $(call Package/tuic/Default,$(component))) \
  $(eval $(call RustBinPackage,tuic-$(component))) \
  $(eval $(call BuildPackage,tuic-$(component))) \
)

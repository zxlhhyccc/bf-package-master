# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2025 openwrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rustup
PKG_VERSION:=1.28.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rust-lang/rustup/tar.gz/$(PKG_VERSION)?
PKG_HASH:=5987dcb828068a4a5e29ba99ab26f2983ac0c6e2e4dc3e5b3a3c0fafb69abbc0

HOST_BUILD_DIR:=$(BUILD_DIR)/host/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Zxl hhyccc <zxlhhy@gmail.com>
PKG_LICENSE:=Apache-2.0 OR MIT
PKG_LICENSE_FILES:=LICENSE-MIT LICENSE-APACHE

PKG_BUILD_DEPENDS:=rust/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/rustup
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust Toolchain
  TITLE:=The Rust toolchain installer (host only)
  URL:=https://github.com/rust-lang/rustup
  DEPENDS:=+libopenssl $(RUST_ARCH_DEPENDS)
endef

define Package/rustup/description
 Rustup is the recommended tool to install the Rust programming language.
 This package only provides a host build tool for OpenWrt build system.
endef

define Host/Compile
	$(CARGO_PKG_CONFIG_VARS) \
	TARGET_CFLAGS="$(filter-out -O%,$(TARGET_CFLAGS)) $(RUSTC_CFLAGS)" \
	OPENSSL_DIR="$(STAGING_DIR_HOST)" \
	OPENSSL_LIB_DIR="$(STAGING_DIR_HOST)/lib" \
	OPENSSL_INCLUDE_DIR="$(STAGING_DIR_HOST)/include" \
	cargo build --release --locked \
		--manifest-path=$(HOST_BUILD_DIR)/Cargo.toml \
		--target-dir=$(HOST_BUILD_DIR)/target \
		$(CARGO_PKG_ARGS)
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/target/release/rustup-init \
		$(STAGING_DIR_HOSTPKG)/bin/rustup
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOSTPKG)/bin/rustup
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rustup))


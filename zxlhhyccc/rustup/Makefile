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
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=MIT LICENSE

PKG_HOST_ONLY:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/rustup
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust Toolchain
  TITLE:=The the Rust toolchain installer
  URL:=https://github.com/rust-lang/rustup
  DEPENDS:=+libopenssl $(RUST_ARCH_DEPENDS)
endef

define Host/Compile
	OPENSSL_DIR="$(STAGING_DIR_HOST)" \
	OPENSSL_LIB_DIR="$(STAGING_DIR_HOST)/lib" \
	OPENSSL_INCLUDE_DIR="$(STAGING_DIR_HOST)/include" \
	PKG_CONFIG_ALLOW_CROSS=1 \
	cargo build --release --locked \
		--manifest-path=$(HOST_BUILD_DIR)/Cargo.toml \
		--target-dir $(HOST_BUILD_DIR)/target
endef

define Host/Install
	$(INSTALL_DIR) $(STAGING_DIR_HOSTPKG)/bin
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/target/release/rustup-init $(STAGING_DIR_HOSTPKG)/bin/rustup
endef

define Host/Clean
	rm -f $(STAGING_DIR_HOSTPKG)/bin/rustup
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,rustup))


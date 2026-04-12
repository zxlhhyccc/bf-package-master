# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2025 openwrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=cross
PKG_VERSION:=0.2.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/cross-rs/cross/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=8dfcad7aa8eb0b9ce18423c386fc03bc709e8c9ad2d7bcb1a77f9d1d1cd6fd2e

PKG_MAINTAINER:=Zxl hhyccc <zxlhhy@gmail.com>
PKG_LICENSE:=Apache-2.0 OR MIT
PKG_LICENSE_FILES:=LICENSE-MIT LICENSE-APACHE

HOST_BUILD_DEPENDS:=rust/host
HOST_BUILD_PARALLEL:=1
PKG_HOST_ONLY:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-host-build.mk

define Package/cross
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Rust Toolchain
  TITLE:=Zero setup cross compilation and cross testing
  URL:=https://github.com/cross-rs/cross
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  BUILDONLY:=1
endef

define Package/$(PKG_NAME)/description
  Cross is a tool for cross compiling Rust projects without any hassle.
endef

$(eval $(call RustBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,cross))


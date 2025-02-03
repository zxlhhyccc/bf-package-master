# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rustdesk-server
PKG_VERSION:=1.1.14
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rustdesk/rustdesk-server.git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_MIRROR_HASH:=e300079a0b442ef4eb4d129338d0d7b1dd1d3505720e20735dac5f6ea65ee93a

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

define Package/rustdesk-server
  SECTION:=net
  CATEGORY:=Network
  TITLE:=RustDesk Server Program
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!(mips||mipsel)
  URL:=https://rustdesk.com/server
endef

define Package/rustdesk-server/description
  Self-host your own RustDesk server, it is free and open source.
endef

$(eval $(call RustBinPackage,rustdesk-server))
$(eval $(call BuildPackage,rustdesk-server))

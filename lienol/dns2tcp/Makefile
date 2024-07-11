# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=dns2tcp
PKG_VERSION:=1.1.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/zfl9/dns2tcp.git
PKG_SOURCE_DATE:=2024-07-11
PKG_SOURCE_VERSION:=0260861a91a540203ba72cccba39d12c42ddc659
PKG_MIRROR_HASH:=911926d6c44948150e435d21ef0d158ff32b3ecdcb5d8a0a485f697ee97095c9

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16 gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/dns2tcp
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=utility to convert dns query from udp to tcp
  URL:=https://github.com/zfl9/dns2tcp
endef

# TARGET_CFLAGS+= $(FPIC) -flto
TARGET_CFLAGS+= $(FPIC)
MAKE_FLAGS+= \
	CFLAGS="-std=c99 $(TARGET_CFLAGS)" \
	EVCFLAGS="$(TARGET_CFLAGS)"

define Package/dns2tcp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dns2tcp $(1)/usr/bin/
endef

$(eval $(call BuildPackage,dns2tcp))

#
# Copyright (C) 2021 CTCGFW Project-OpenWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tmate
PKG_VERSION:=2.4.0
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/tmate-io/tmate.git
PKG_SOURCE_DATE:=2021-02-21
PKG_SOURCE_VERSION:=f6a4ae6042f4bb2b6db8eda23df31d8b788a7978
PKG_MIRROR_HASH:=daade96ea794fd9fb0452c7ea5e4c768441ee64e85deabc05c19deef20ffc377

PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=CN_SZTL <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=ncurses
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tmate
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SSH
  TITLE:=Instant Terminal Sharing
  URL:=https://tmate.io
  DEPENDS:=+libpthread +libevent2 +libssh +libmsgpack-c +libncurses
endef

CONFIGURE_ARGS+= \
	--oldincludedir=$(STAGING_DIR)

CONFIGURE_VARS+= \
	LIBSSH_CFLAGS="-I$(STAGING_DIR)/usr/include" \
	LIBSSH_LIBS="-lssh"

define Package/tmate/description
	Tmate is a fork of tmux. It provides an instant pairing solution.
endef

define Package/tmate/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tmate $(1)/usr/bin/tmate
endef

$(eval $(call BuildPackage,tmate))

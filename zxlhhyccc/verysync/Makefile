#
# Copyright (C) 2021 CTCGFW Project-OpenWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

ifeq ($(ARCH),x86_64)
	PKG_ARCH_VERYSYNC:=amd64
endif
ifeq ($(ARCH),mipsel)
	PKG_ARCH_VERYSYNC:=mipsle
endif
ifeq ($(ARCH),mips)
	PKG_ARCH_VERYSYNC:=mips
endif
ifeq ($(ARCH),i386)
	PKG_ARCH_VERYSYNC:=386
endif
ifeq ($(ARCH),arm)
	PKG_ARCH_VERYSYNC:=arm
endif
ifeq ($(ARCH),aarch64)
	PKG_ARCH_VERYSYNC:=arm64
endif
ifeq ($(ARCH),powerpc64)
	PKG_ARCH_VERYSYNC:=ppc64
endif

PKG_NAME:=verysync
PKG_VERSION:=v2.4.3
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-linux-$(PKG_ARCH_VERYSYNC)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://dl.verysync.com/releases/$(PKG_VERSION)/
PKG_HASH:=skip

PKG_CONFIG_DEPENDS:= \
	CONFIG_VERYSYNC_COMPRESS_UPX

include $(INCLUDE_DIR)/package.mk

TAR_CMD:=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Package/verysync
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A efficient data transmission tool
	URL:=http://www.verysync.com
endef

define Package/verysync/description
	Verysync is a efficient data transmission tool.
endef

define Package/verysync/config
	config VERYSYNC_COMPRESS_UPX
		bool "Compress executable files with UPX"
		default y
endef

define Build/Configure
	true
ifeq ($(CONFIG_VERYSYNC_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/verysync-linux-$(PKG_ARCH_VERYSYNC)-$(PKG_VERSION)/verysync
endif
endef

define Build/Compile
	true
endef

define Package/verysync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/verysync-linux-$(PKG_ARCH_VERYSYNC)-$(PKG_VERSION)/verysync $(1)/usr/bin/verysync
endef

$(eval $(call BuildPackage,verysync))

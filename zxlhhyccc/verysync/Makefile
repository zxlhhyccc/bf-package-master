#
# Copyright (C) 2021 CTCGFW Project-OpenWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

ifeq ($(ARCH),aarch64)
  PKG_ARCH_VERYSYNC:=arm64
  PKG_HASH_VERYSYNC:=a907425c747fce6bdf2b76ba5a49f19357370b666c6c833f66d8ea60d4fe3416
else ifeq ($(ARCH),arm)
  PKG_ARCH_VERYSYNC:=arm
  PKG_HASH_VERYSYNC:=187e30c44d855742dd9f70ba6214e5c0211bebf357e6cd39c6dea48d5f6422be
else ifeq ($(ARCH),i386)
  PKG_ARCH_VERYSYNC:=386
  PKG_HASH_VERYSYNC:=9f6dcf10e612be1a36b6df61298949238d3ef3349897ca98ee7c6cbbf163b6b7
else ifeq ($(ARCH),mips)
  PKG_ARCH_VERYSYNC:=mips
  PKG_HASH_VERYSYNC:=50985d17f553756d96444960f3994e29b9756b995debc671bc8d924610902606
else ifeq ($(ARCH),mipsel)
  PKG_ARCH_VERYSYNC:=mipsle
  PKG_HASH_VERYSYNC:=a76e5e248823d1445618de83ee1ee6aae794330e69bca2425481f128219efab1
else ifeq ($(ARCH),powerpc64)
  PKG_ARCH_VERYSYNC:=ppc64
  PKG_HASH_VERYSYNC:=81063277f7148bfe5cea3fa886c36fdf79776a4c65e39683d0b96fde3e91709b
else ifeq ($(ARCH),x86_64)
  PKG_ARCH_VERYSYNC:=amd64
  PKG_HASH_VERYSYNC:=de25e4849a060b09bd4501a1d712cbae1ef320b886ca17938d2222e735be5b16
endif

PKG_NAME:=verysync
PKG_VERSION:=2.20.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-linux-$(PKG_ARCH_VERYSYNC)-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://dl.verysync.com/releases/v$(PKG_VERSION)/ \
		http://dl-cn.verysync.com/releases/v$(PKG_VERSION)/
PKG_HASH:=$(PKG_HASH_VERYSYNC)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-linux-$(PKG_ARCH_VERYSYNC)-v$(PKG_VERSION)

PKG_CONFIG_DEPENDS:= \
	CONFIG_VERYSYNC_COMPRESS_UPX

include $(INCLUDE_DIR)/package.mk

# TAR_CMD:=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)


define Package/verysync
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A efficient data transmission tool
	URL:=http://www.verysync.com
	DEPENDS:=@(aarch64||arm||i386||mips||mipsel||powerpc64||x86_64)
endef

define Package/verysync/description
	Verysync is a efficient data transmission tool.
endef

define Package/verysync/config
	config VERYSYNC_COMPRESS_UPX
		bool "Compress executable files with UPX"
		depends on !mips64
		default n
endef

define Build/Configure
endef

define Build/Compile
	$(call Package/Build/Compile)
ifeq ($(CONFIG_VERYSYNC_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/verysync
endif
endef

define Package/verysync/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/verysync $(1)/usr/bin/verysync
endef

$(eval $(call BuildPackage,verysync))

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
  PKG_HASH_VERYSYNC:=69f1870ae8946bd0a51efd710d92189a94e82ad7d737afc72d98e449ebf26058
else ifeq ($(ARCH),arm)
  PKG_ARCH_VERYSYNC:=arm
  PKG_HASH_VERYSYNC:=fd1d61b65de3c10f2d918c24e8fe8ea2e97776a588fc3b4470f2479e61073d9e
else ifeq ($(ARCH),i386)
  PKG_ARCH_VERYSYNC:=386
  PKG_HASH_VERYSYNC:=9a2ba4841cae1c088f9fd011b6312895e650b32570b4e15e8baefd496b36bb8b
else ifeq ($(ARCH),mips)
  PKG_ARCH_VERYSYNC:=mips
  PKG_HASH_VERYSYNC:=ca398ceb13ef156f721f0d9764fe12438f9ae2590cefd77340dc701444c41573
else ifeq ($(ARCH),mipsel)
  PKG_ARCH_VERYSYNC:=mipsle
  PKG_HASH_VERYSYNC:=91de902c7c9bfa63cc7d193f7d3360f6deb5712e38bdb546531655e1567deb61
else ifeq ($(ARCH),powerpc64)
  PKG_ARCH_VERYSYNC:=ppc64
  PKG_HASH_VERYSYNC:=8aae5540c95614a9450d37d77206fe5967cbe259bbfb92c47accc7f86cf7bc4e
else ifeq ($(ARCH),x86_64)
  PKG_ARCH_VERYSYNC:=amd64
  PKG_HASH_VERYSYNC:=8901e59f3e679e1df366f5abcb77982d7694fe5b32d7afd458ecb3af9676cab6
endif

PKG_NAME:=verysync
PKG_VERSION:=2.19.0
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

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
  PKG_HASH_VERYSYNC:=708702fa19c321acb7e1aaa895a6f2cf8cb6189ab8ede6edf5049b61ad1f0ae0
else ifeq ($(ARCH),arm)
  PKG_ARCH_VERYSYNC:=arm
  PKG_HASH_VERYSYNC:=005ace647231cc8714b8d944dc8bc4376f4d86dd1198eae61e25ef99112a31a6
else ifeq ($(ARCH),i386)
  PKG_ARCH_VERYSYNC:=386
  PKG_HASH_VERYSYNC:=26a5230a414ffc82a3b63d82e2d3ca615784048a4cc8d06e1f8c17ea8beab26a
else ifeq ($(ARCH),mips)
  PKG_ARCH_VERYSYNC:=mips
  PKG_HASH_VERYSYNC:=16ee91434add7aaafe4aa201d2c547d7f4af8abf804056e06b00d2b80c883ee3
else ifeq ($(ARCH),mipsel)
  PKG_ARCH_VERYSYNC:=mipsle
  PKG_HASH_VERYSYNC:=7b2e51ec5b017350dd37497a8203f1effc2e98059ccec104944dfbe82a9c6536
else ifeq ($(ARCH),powerpc64)
  PKG_ARCH_VERYSYNC:=ppc64le
  PKG_HASH_VERYSYNC:=c1115c498d40fcf6c1e0cfadd5176fa5230fce56cb937e61c76a210ffa7565f7
else ifeq ($(ARCH),x86_64)
  PKG_ARCH_VERYSYNC:=amd64
  PKG_HASH_VERYSYNC:=8a4b347669cd33def98b3bf1888576c8dc786ed77485080901bba0101c4413bd
endif

PKG_NAME:=verysync
PKG_VERSION:=2.33.2
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

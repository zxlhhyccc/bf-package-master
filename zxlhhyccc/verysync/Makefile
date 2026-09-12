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
  PKG_HASH_VERYSYNC:=763552d4ee76abbe905c34d3cc8333f9284ab14abe911d0b76e85f1d3487baf6
else ifeq ($(ARCH),arm)
  PKG_ARCH_VERYSYNC:=arm
  PKG_HASH_VERYSYNC:=db72f9d925cb5172417e25369d5da63b042851cf76d64b16a5fa310fd8e09dcf
else ifeq ($(ARCH),i386)
  PKG_ARCH_VERYSYNC:=386
  PKG_HASH_VERYSYNC:=4794ef2440efe1c4bb6ba94bb02e884c4c62588a7db95b49b630de3335b3a3d0
else ifeq ($(ARCH),mips)
  PKG_ARCH_VERYSYNC:=mips
  PKG_HASH_VERYSYNC:=4f8d27414e09a27235cf770aa791030b866d0b83fc1305730ec601ec1b38b4ce
else ifeq ($(ARCH),mipsel)
  PKG_ARCH_VERYSYNC:=mipsle
  PKG_HASH_VERYSYNC:=080cc4b9a39e4dbaa0f03f2bb97bc73b33aac488085739e99a6e742ec6c6e327
else ifeq ($(ARCH),powerpc64)
  PKG_ARCH_VERYSYNC:=ppc64le
  PKG_HASH_VERYSYNC:=a7f23c2defa65f750414ce8f81dd2692ed00e9507f9f80f0761ddde746b3c92b
else ifeq ($(ARCH),x86_64)
  PKG_ARCH_VERYSYNC:=amd64
  PKG_HASH_VERYSYNC:=e58c2f98d9921899709f2802fb4c5df6d2230d564d35e28d98b78c9245f76fdd
endif

PKG_NAME:=verysync
PKG_VERSION:=2.30.1
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

#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-meta
PKG_VERSION:=alpha
PKG_RELEASE:=gdbffbca

ifeq ($(ARCH),mipsel)
	OPENCLASH_META_ARCH:=mipsle-softfloat
endif
ifeq ($(ARCH),mips)
	OPENCLASH_META_ARCH:=mips64
endif
ifeq ($(ARCH),i386)
	OPENCLASH_META_ARCH:=386
endif
ifeq ($(ARCH),x86_64)
	OPENCLASH_META_ARCH:=amd64
endif
ifeq ($(ARCH),arm)
	OPENCLASH_META_ARCH:=armv7
endif
ifeq ($(BOARD),bcm53xx)
	OPENCLASH_META_ARCH:=armv6
ifeq ($(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE)))),)
	OPENCLASH_META_ARCH:=armv5
endif
endif
ifeq ($(BOARD),kirkwood)
	OPENCLASH_META_ARCH:=armv5
endif
ifeq ($(ARCH),aarch64)
	OPENCLASH_META_ARCH:=armv8
endif

PKG_LICENSE:=Apache-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/clash-$(PKG_VERSION)-$(PKG_RELEASE)
# PKG_SOURCE:=clash-linux-$(OPENCLASH_META_ARCH).tar.gz
# PKG_SOURCE_URL:=https://github.com/vernesong/OpenClash/releases/download/TUN/
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=openclash-meta is a cross-platform proxy software
	DEPENDS:=+kmod-tun
	URL:=https://github.com/frainzy1477/clash_dev/releases
endef

define Package/$(PKG_NAME)/description
openclash-meta is a cross-platform proxy software
endef

define Build/Prepare
	[ ! -f $(PKG_BUILD_DIR)/clash-linux-$(OPENCLASH_META_ARCH).tar.gz ] && wget https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$(OPENCLASH_META_ARCH).tar.gz -O $(PKG_BUILD_DIR)/clash-linux-$(OPENCLASH_META_ARCH).tar.gz
	tar -xzvf $(PKG_BUILD_DIR)/clash-linux-$(OPENCLASH_META_ARCH).tar.gz -C $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clash $(1)/etc/openclash/core/clash_meta
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

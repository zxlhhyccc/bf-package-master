# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2023 Yousong Zhou <yszhou4tech@gmail.com>
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-premium
PKG_VERSION:=2023.08.17
PKG_RELEASE:=13-gdcc8d87

# PKG_SOURCE_URL:=https://release.dreamacro.workers.dev/latest/
PKG_SOURCE_URL:=https://github.com/zxlhhyccc/openclash-premium/releases/download/$(PKG_VERSION)-$(PKG_RELEASE)
UNPACK_CMD=gzip -dc $(DL_DIR)/$(PKG_SOURCE) > $(DL_DIR)/clash_tun && $(INSTALL_BIN) $(DL_DIR)/clash_tun $(PKG_BUILD_DIR)/clash_tun

TUN_TYPE:=clash-linux
TUN_FOOT:=latest
TUN_FOOTER:=gz
ifeq ($(ARCH),aarch64)
  PKG_SOURCE:=$(TUN_TYPE)-arm64-$(TUN_FOOT).$(TUN_FOOTER)
  PKG_HASH:=ac7a590f4fcfc329e0a65689ad5cb3d300130307f263ad677da37e0bce3e302a
else ifeq ($(ARCH),arm)
# Referred to golang/golang-values.mk
    PKG_SOURCE:=$(TUN_TYPE)-armv7-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=1d0f7b20fa4b0822b317f362005204549d734bf2e6cd056a72cc2bc01b89d37e
  ifneq ($(CONFIG_TARGET_BOARD),"bcm53xx")
    PKG_SOURCE:=$(TUN_TYPE)-armv6-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=4bba3c4915c4f09b78bbb97decb68ea8fbebfdfd9f39ec861de987d1e54e1130
    ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifneq ($(ARM_CPU_FEATURES),)
    PKG_SOURCE:=$(TUN_TYPE)-armv5-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=b1ef051034ee379dc3c6edbdb4c6e4bdf97fec69d242967e2d5ab0972e82a76b
  endif
endif
  ifeq ($(CONFIG_TARGET_BOARD),"kirkwood")
    PKG_SOURCE:=$(TUN_TYPE)-armv5-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=b1ef051034ee379dc3c6edbdb4c6e4bdf97fec69d242967e2d5ab0972e82a76b
endif
else ifeq ($(ARCH),mips)
    PKG_SOURCE:=$(TUN_TYPE)-mips-softfloat-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=b94e50b990cda3933715ccb43f22b7b3d42f179f187fad5f71eaa7cf2de23905
  ifneq ($(CONFIG_HAS_FPU),y)
    PKG_SOURCE:=$(TUN_TYPE)-mips-hardfloat-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=7eb6951ea709d30c1debbb59e16dd26092deb00b5f6d70564ae8140973aee374
  endif
else ifeq ($(ARCH),mips64)
    PKG_SOURCE:=$(TUN_TYPE)-mips64-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=95b2d6356f8ce0cc052aa7306a7c328f7a667a157d331a63aa875fccb80c0bf0
else ifeq ($(ARCH),mips64le)
    PKG_SOURCE:=$(TUN_TYPE)-mips64le-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=2ab0164a4651d6462a19320796de63c8bbc613a2f7e4a8fd66f2c1ecdfc3cb5c
else ifeq ($(ARCH),mipsle)
    PKG_SOURCE:=$(TUN_TYPE)-mipsle-softfloat-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=59b7727d37f30dd1cdbedc43da8d94920ca2262d0c36398c90a54dd99ddd50a4
  ifneq ($(CONFIG_HAS_FPU),y)
    PKG_SOURCE:=$(TUN_TYPE)-mipsle-hardfloat-$(TUN_FOOT).$(TUN_FOOTER)
    PKG_HASH:=acb271b5c5b8a249078d945a93fa2cc348bd5544db41894a018a5a96be662d7e
  endif
else ifeq ($(ARCH),i386)
  PKG_SOURCE:=$(TUN_TYPE)-386-$(TUN_FOOT).$(TUN_FOOTER)
  PKG_HASH:=5defcf7c521fcd2c0278493fe9df6b2ed2675536ea2adb8a2b58e5ac46b4553b
else ifeq ($(ARCH),x86_64)
  PKG_SOURCE:=$(TUN_TYPE)-amd64-$(TUN_FOOT).$(TUN_FOOTER)
  PKG_HASH:=6b83dd798ad276e7ebb4bdd21acbac51183ffff16e7e20aac9ae6e1d593594a9
# Set the default value to make OpenWrt Package Checker happy
else
  PKG_SOURCE:=dummy
  PKG_HASH:=dummy
endif

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_OPENCLASH-PREMIUM_COMPRESS_UPX

include $(INCLUDE_DIR)/package.mk

define Package/openclash-premium
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=openclash-tun is a cross-platform proxy software
	DEPENDS:=@USE_MUSL @(aarch64||arm||mips||mips64||mips64le||mipsle||i386||x86_64) @!(TARGET_x86_geode||TARGET_x86_legacy) +kmod-tun
	URL:=https://github.com/frainzy1477/clash_dev/releases
endef

define Package/openclash-premium/description
	Clash, A rule based tunnel in Go, support VMess, Shadowsocks,
	Trojan, Snell protocol for remote connections.
endef

define Package/openclash-premium/config
  config OPENCLASH-PREMIUM_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

define Build/Compile
	$(call Package/Build/Compile)
ifeq ($(CONFIG_OPENCLASH-PREMIUM_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/clash_tun
endif
endef

define Package/openclash-premium/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clash_tun $(1)/etc/openclash/core/clash_tun
endef

$(eval $(call BuildPackage,openclash-premium))

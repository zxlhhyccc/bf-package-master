#
# Copyright (C) 2017-2020 Yousong Zhou <yszhou4tech@gmail.com>
#
# Copyright (C) 2021 ImmortalWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=shadowsocks-rust
PKG_VERSION:=1.11.2
PKG_RELEASE:=1

PKG_SOURCE_HEADER:=shadowsocks-v$(PKG_VERSION)
PKG_SOURCE_BODY:=unknown-linux-musl
PKG_SOURCE_FOOTER:=tar.xz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-rust/releases/download/v$(PKG_VERSION)/

ifeq ($(ARCH),aarch64)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).aarch64-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=4f4d0cb9687a152e8be0ecb73576821dbc6631f34bb0253f520c988f71b851f6
else ifeq ($(ARCH),arm)
  # Referred to golang/golang-values.mk
  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifeq ($(ARM_CPU_FEATURES),)
    PKG_SOURCE:=$(PKG_SOURCE_HEADER).arm-$(PKG_SOURCE_BODY)eabi.$(PKG_SOURCE_FOOTER)
    PKG_HASH:=5e037a72c27a87a097fea443ab337d51f1c9cc311857d4757b438acc27f38260
  else ifneq ($(filter $(ARM_CPU_FEATURES),vfp vfpv2),)
    PKG_SOURCE:=$(PKG_SOURCE_HEADER).arm-$(PKG_SOURCE_BODY)eabihf.$(PKG_SOURCE_FOOTER)
    PKG_HASH:=f3eb7f1cf23959e3df6dbb352996fa47fa1345b07a61e993f68d1c479227d7a1
  #else
  #  PKG_SOURCE:=$(PKG_SOURCE_HEADER).armv7-$(PKG_SOURCE_BODY)eabihf.$(PKG_SOURCE_FOOTER)
  #  PKG_HASH:=92947b817fd11dafb172ebc2a7c72228efe208e9067d385c0b6063ed99587737
  endif
else ifeq ($(ARCH),i386)
  ifeq ($(CONFIG_TARGET_x86_geode)$(CONFIG_TARGET_x86_legacy),y)
  #  PKG_SOURCE:=$(PKG_SOURCE_HEADER).i586-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  #  PKG_HASH:=d158446f0cde52d91ef22df3564cee86c7b24b659c9a4d3054b6ec4fe3669a4e
  #else
    PKG_SOURCE:=$(PKG_SOURCE_HEADER).i686-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
    PKG_HASH:=3673ca20b050860797dd34030f4b1bc0ed6da36f296e26e45932bf836cd2c5e2
  endif
else ifeq ($(ARCH),mips)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).mips-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=1d23f0f7fc3e14d6d69a163ce407a6c6e9e046cfc9853f4da37b28e4cae310d0
else ifeq ($(ARCH),mipsel)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).mipsel-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=3d2f51e7e3b2845ae147282fba2adea87dfe2fd097ab1eb606f696876280cce6
else ifeq ($(ARCH),x86_64)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).x86_64-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=c61220c05049e4a45a6a18b4a7cc33f77e9b0bc9143e29433be20d6c5c35f585
# Set the default value to make OpenWrt Package Checker happy
else
  PKG_SOURCE:=dummy
  PKG_HASH:=dummy
endif

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

TAR_CMD:=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Package/shadowsocks-rust/Default
  PKG_CONFIG_DEPENDS+=CONFIG_SHADOWSOCKS_RUST_$(1)_COMPRESS_UPX

  define Package/shadowsocks-rust-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=shadowsocks-rust $(1)
    URL:=https://github.com/shadowsocks/shadowsocks-rust
    DEPENDS:=@(aarch64||arm||i386||mips||mipsel||x86_64) @USE_MUSL
  endef

  define Package/shadowsocks-rust-$(1)/config
    config SHADOWSOCKS_RUST_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      default y
  endef

  define Package/shadowsocks-rust-$(1)/install
	$$(INSTALL_DIR) $$(1)/usr/bin
	$$(INSTALL_BIN) $$(PKG_BUILD_DIR)/$(1) $$(1)/usr/bin
  endef
endef

PKG_CONFIG_DEPENDS:=
SHADOWSOCKS_COMPONENTS:=sslocal ssmanager ssserver ssurl
define shadowsocks-rust/templates
  $(foreach component,$(SHADOWSOCKS_COMPONENTS),
    $(call Package/shadowsocks-rust/Default,$(component))
  )
endef
$(eval $(call shadowsocks-rust/templates))

define Build/Compile
$(foreach component,$(SHADOWSOCKS_COMPONENTS),
  ifneq ($(CONFIG_SHADOWSOCKS_RUST_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/$(component)
  endif
)
endef

$(foreach component,$(SHADOWSOCKS_COMPONENTS), \
  $(eval $(call BuildPackage,shadowsocks-rust-$(component))) \
)

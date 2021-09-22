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
PKG_VERSION:=1.12.0-alpha.4
PKG_RELEASE:=1

PKG_SOURCE_HEADER:=shadowsocks-v$(PKG_VERSION)
PKG_SOURCE_BODY:=unknown-linux-musl
PKG_SOURCE_FOOTER:=tar.xz
PKG_SOURCE_URL:=https://github.com/shadowsocks/shadowsocks-rust/releases/download/v$(PKG_VERSION)/

ifeq ($(ARCH),aarch64)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).aarch64-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=5c88d6c9c63abf798537bbac246249eef578e6eaddda99b8026f35cd5517d0de
else ifeq ($(ARCH),arm)
  # Referred to golang/golang-values.mk
  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifeq ($(ARM_CPU_FEATURES),)
    PKG_SOURCE:=$(PKG_SOURCE_HEADER).arm-$(PKG_SOURCE_BODY)eabi.$(PKG_SOURCE_FOOTER)
    PKG_HASH:=5f554d0e939a8f248bb158e10fa3f7bc746f69b793dea40e29cd9df11ec1f179
  else ifneq ($(filter $(ARM_CPU_FEATURES),vfp vfpv2),)
    PKG_SOURCE:=$(PKG_SOURCE_HEADER).arm-$(PKG_SOURCE_BODY)eabihf.$(PKG_SOURCE_FOOTER)
    PKG_HASH:=eddb632f62877a67e989f983b99a357ebbd9741c2220e1cc91653506fb8256d0
  #else
  #  PKG_SOURCE:=$(PKG_SOURCE_HEADER).armv7-$(PKG_SOURCE_BODY)eabihf.$(PKG_SOURCE_FOOTER)
  #  PKG_HASH:=b183ca95caefc3c314ba962e7276d1955713a7e07f39c900cc97c3f666707c98
  endif
else ifeq ($(ARCH),i386)
  ifeq ($(CONFIG_TARGET_x86_geode)$(CONFIG_TARGET_x86_legacy),y)
  #  PKG_SOURCE:=$(PKG_SOURCE_HEADER).i586-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  #  PKG_HASH:=d158446f0cde52d91ef22df3564cee86c7b24b659c9a4d3054b6ec4fe3669a4e
  #else
    PKG_SOURCE:=$(PKG_SOURCE_HEADER).i686-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
    PKG_HASH:=f6d9efbc4de233ee90c15966347b233a02d751c6e7acc4a1f0bba78e03324766
  endif
else ifeq ($(ARCH),mips)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).mips-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=d3591a62b53aa55045e6087808aef047e67c8558c7b59dbe412066992accdc40
else ifeq ($(ARCH),mipsel)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).mipsel-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=57a2988989e21161815c38a8706acd55a63aed4febafcc9e561e36fccc9812af
else ifeq ($(ARCH),x86_64)
  PKG_SOURCE:=$(PKG_SOURCE_HEADER).x86_64-$(PKG_SOURCE_BODY).$(PKG_SOURCE_FOOTER)
  PKG_HASH:=b04efa059fdafe29365f4bd87dee64fcd60f1437c7ef7a3fc4f4190ae184f01a
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

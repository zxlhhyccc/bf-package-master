# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=shadow-tls
PKG_VERSION:=0.2.25
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/ihciah/shadow-tls/releases/download/v$(PKG_VERSION)
UNPACK_CMD=$(INSTALL_BIN) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/shadow-tls

RELEASE_HEAD:=$(PKG_NAME)
RELEASE_FOOT:=unknown-linux-musl
ifeq ($(ARCH),aarch64)
  PKG_SOURCE:=$(RELEASE_HEAD)-aarch64-$(RELEASE_FOOT)
  PKG_HASH:=3295476b37f549a68906519d3eaecb74bf3b6eaf9094cebb16ee84f0151373c6
else ifeq ($(ARCH),arm)
  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifeq ($(ARM_CPU_FEATURES),cortex-a7)
    PKG_SOURCE:=$(RELEASE_HEAD)-armv7-$(RELEASE_FOOT)eabihf
    PKG_HASH:=e6f918a072557c50fd0ea950af9a156a9b102af72c1d010ff85d08d13006c54f
  else ifeq ($(ARM_CPU_FEATURES),cortex-a9)
    PKG_SOURCE:=$(RELEASE_HEAD)-armv7-$(RELEASE_FOOT)eabihf
    PKG_HASH:=e6f918a072557c50fd0ea950af9a156a9b102af72c1d010ff85d08d13006c54f
  else
    PKG_SOURCE:=$(RELEASE_HEAD)-arm-$(RELEASE_FOOT)eabi
    PKG_HASH:=b6743bc60e1727972ece0fd5acf3a931e5be05cedee6f637e7e3d8c5b8d58f16
  endif
else ifeq ($(ARCH),x86_64)
  PKG_SOURCE:=$(RELEASE_HEAD)-x86_64-$(RELEASE_FOOT)
  PKG_HASH:=a173f5f2d57f45211b68e10ceeddc15b1791077b914fa89747bc705fddc71532
else
  PKG_SOURCE:=dummy
  PKG_HASH:=dummy
endif

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=FluffyTigerFear

PKG_CONFIG_DEPENDS:= \
  CONFIG_SHADOW-TLS_COMPRESS_UPX

include $(INCLUDE_DIR)/package.mk

define Package/shadow-tls
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=A proxy to expose real tls handshake to the firewall.
	URL:=https://github.com/ihciah/shadow-tls
	DEPENDS:=@USE_MUSL @(aarch64||arm||x86_64) @!(TARGET_x86_geode||TARGET_x86_legacy)
endef

define Package/shadow-tls/config
  config SHADOW-TLS_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

define Build/Compile
	$(call Package/Build/Compile)
ifeq ($(CONFIG_SHADOW-TLS_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/shadow-tls
endif
endef

define Package/shadow-tls/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/shadow-tls $(1)/usr/bin
endef

$(eval $(call BuildPackage,shadow-tls))

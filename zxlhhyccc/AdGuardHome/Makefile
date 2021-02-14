# Copyright (C) 2020 xiaorouji
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=AdGuardHome
PKG_VERSION:=0.105.0
PKG_RELEASE:=1

ifeq ($(ARCH),i386)
	PKG_ARCH:=386
endif
ifeq ($(ARCH),x86_64)
	PKG_ARCH:=amd64
endif
ifeq ($(ARCH),mipsel)
	PKG_ARCH:=mipsle_softfloat
endif
ifeq ($(ARCH),mips)
	PKG_ARCH:=mips_softfloat
endif
ifeq ($(ARCH),arm)
	PKG_ARCH:=arm7
endif
ifeq ($(BOARD),bcm53xx)
	PKG_ARCH:=arm6
ifeq ($(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE)))),)
	PKG_ARCH:=arm5
endif
endif
ifeq ($(BOARD),kirkwood)
	PKG_ARCH:=arm5
endif
ifeq ($(ARCH),arm64)
	PKG_ARCH:=arm64
endif
ifeq ($(ARCH),aarch64)
	PKG_ARCH:=arm64
endif

PKG_SOURCE:=$(PKG_NAME)_linux_$(PKG_ARCH).tar.gz
PKG_SOURCE_URL:=https://github.com/AdguardTeam/AdGuardHome/releases/download/v$(PKG_VERSION)/
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_linux_$(PKG_ARCH)
PKG_HASH:=skip

include $(INCLUDE_DIR)/package.mk

TAR_CMD:=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Package/AdGuardHome
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Network-wide ads & trackers blocking DNS server
	URL:=https://github.com/AdguardTeam/AdGuardHome
endef

define Package/AdGuardHome/description
Network-wide ads & trackers blocking DNS server
endef

define Build/Configure
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/AdGuardHome/AdGuardHome || true
endef

define Build/Compile
	true
endef

define Package/AdGuardHome/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/AdGuardHome/AdGuardHome $(1)/usr/bin/AdGuardHome
	$(INSTALL_DIR) $(1)/etc/AdGuardHome
	$(INSTALL_CONF) ./files/AdGuardHome.yaml $(1)/etc/AdGuardHome/AdGuardHome.yaml
endef

$(eval $(call BuildPackage,AdGuardHome))

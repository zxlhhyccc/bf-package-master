#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=AdGuardHome-53xx
PKG_VERSION:=v0.101.0
PKG_RELEASE:=35-gc5a3

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	TITLE:=AdGuardHome-k3
	DEPENDS:=
	URL:=https://github.com/AdguardTeam/AdGuardHome/releases
endef

define Package/$(PKG_NAME)/description
AdGuardHome
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/AdGuardHome $(1)/usr/bin/AdGuardHome
	$(INSTALL_DIR) $(1)/etc/AdGuardHome
	$(CP) -r ./files/etc/AdGuardHome $(1)/etc
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

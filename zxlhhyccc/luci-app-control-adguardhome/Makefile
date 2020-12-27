# Copyright (C) 2018-2019 Lienol
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-control-adguardhome
PKG_VERSION:=0.102.0
PKG_RELEASE:=20200516

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-control-adguardhome
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI app for adguardhome
	PKG_MAINTAINER:=<https://github.com/rufengsuixing/luci-app-adguardhome>
	PKGARCH:=all
	DEPENDS:=+!wget-ssl&&!curl:wget-ssl
endef

define Package/luci-app-control-adguardhome/description
	LuCI support for adguardhome
endef

define Build/Prepare
endef

define Build/Compile
endef

define Package/luci-app-control-adguardhome/conffiles
/etc/config/AdGuardHome
endef

define Package/luci-app-control-adguardhome/install
    $(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
endef

define Package/luci-app-control-adguardhome/postinst
#!/bin/sh
	/etc/init.d/AdGuardHome enable >/dev/null 2>&1
	enable=$(uci get AdGuardHome.AdGuardHome.enabled 2>/dev/null)
	if [ "$enable" == "1" ]; then
		/etc/init.d/AdGuard-Home reload
	fi
	rm -f /tmp/luci-indexcache
	rm -f /tmp/luci-modulecache/*
exit 0
endef

define Package/luci-app-control-adguardhome/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/AdGuard-Home disable
     /etc/init.d/AdGuard-Home stop
uci -q batch <<-EOF >/dev/null 2>&1
	delete ucitrack.@AdGuardHome[-1]
	commit ucitrack
EOF
fi
exit 0
endef

$(eval $(call BuildPackage,luci-app-control-adguardhome))

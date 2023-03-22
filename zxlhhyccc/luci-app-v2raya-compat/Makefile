# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-v2raya-compat
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

PKG_MAINTAINER:=zxlhhyccc <zxlhhy@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2raya-v5 \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2raya \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_NONE_V2RAY \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2ray \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2ray_V5 \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_Xray

LUCI_TITLE:=LuCI support for v2rayA
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+luci-compat \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2raya-v5:v2raya-v5 \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2raya:v2raya \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2ray:v2ray-core \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2ray_V5:v2ray-core-v5 \
	+PACKAGE_$(PKG_NAME)_INCLUDE_Xray:xray-core

define Package/$(PKG_NAME)/config
select PACKAGE_luci-lib-ipkg if PACKAGE_$(PKG_NAME)
choice
	prompt "V2ray-core Selection"
	default PACKAGE_$(PKG_NAME)_INCLUDE_NONE_V2RAY

	config PACKAGE_$(PKG_NAME)_INCLUDE_NONE_V2RAY
	bool "None"

	config PACKAGE_$(PKG_NAME)_INCLUDE_V2ray
	bool "V2ray-core"

	config PACKAGE_$(PKG_NAME)_INCLUDE_V2ray_V5
	bool "V2ray-core-v5"

	config PACKAGE_$(PKG_NAME)_INCLUDE_Xray
	bool "Xray-core"
endchoice

	config PACKAGE_$(PKG_NAME)_INCLUDE_V2raya-v5
	bool "Include V2raya-v5"
	default y

	config PACKAGE_$(PKG_NAME)_INCLUDE_V2raya
	bool "Include V2raya"
	default n
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/v2raya
/etc/v2raya/
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
	/etc/init.d/v2raya enable >/dev/null 2>&1
	enable=$$(uci get v2raya.config.enabled 2>/dev/null)
	if [ "$$enable" == "1" ]; then
		/etc/init.d/v2raya reload
	fi
	rm -f /tmp/luci-indexcache
	rm -f /tmp/luci-modulecache/*
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh

if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/v2raya disable
     /etc/init.d/v2raya stop
uci -q batch <<-EOF >/dev/null 2>&1
	delete ucitrack.@v2raya[-1]
	commit ucitrack
EOF
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

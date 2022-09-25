# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-v2raya
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2raya-v5 \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2raya \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_NONE_V2RAY \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_V2ray \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_Xray \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_SagerNet_Core

LUCI_TITLE:=LuCI support for v2rayA
LUCI_PKGARCH:=all
LUCI_DEPENDS:= \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2raya-v5:v2raya-v5 \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2raya:v2raya \
	+PACKAGE_$(PKG_NAME)_INCLUDE_V2ray:v2ray-core \
	+PACKAGE_$(PKG_NAME)_INCLUDE_Xray:xray-core \
	+PACKAGE_$(PKG_NAME)_INCLUDE_SagerNet_Core:sagernet-core

define Package/$(PKG_NAME)/config
select PACKAGE_luci-lib-ipkg if PACKAGE_$(PKG_NAME)
choice
	prompt "V2ray-core Selection"
	default PACKAGE_$(PKG_NAME)_INCLUDE_SagerNet_Core
	default PACKAGE_$(PKG_NAME)_INCLUDE_NONE_V2RAY

	config PACKAGE_$(PKG_NAME)_INCLUDE_NONE_V2RAY
	bool "None"

	config PACKAGE_$(PKG_NAME)_INCLUDE_V2ray
	bool "V2ray-core"

	config PACKAGE_$(PKG_NAME)_INCLUDE_Xray
	bool "Xray-core"

	config PACKAGE_$(PKG_NAME)_INCLUDE_SagerNet_Core
	bool "SagerNet-core (An enhanced edition of v2ray-core)"
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

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

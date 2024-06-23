# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-control-openvpn-server
PKG_VERSION:=1.0
PKG_RELEASE:=3

LUCI_TITLE:=LuCI support for OpenVPN Server
LUCI_DEPENDS:=+openvpn-server-openssl +openvpn-easy-rsa-whisky +luci-compat
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/conffiles
/etc/openvpn/
/etc/config/openvpn
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/openvpn-server) && rm -f /etc/uci-defaults/openvpn-server
	exit 0
}
endef

# call BuildPackage - OpenWrt buildroot signature

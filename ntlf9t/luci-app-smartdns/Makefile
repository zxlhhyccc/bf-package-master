# This is free software, licensed under the Apache License, Version 2.0 .

include $(TOPDIR)/rules.mk

LUCI_TITLE:=Luci for smartdns server
LUCI_DEPENDS:=+luci-compat +smartdns
LUCI_PKGARCH:=all

PKG_NAME:=luci-app-smartdns
PKG_VERSION:=1.2022.08.31-2206
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-smartdns/postinst
[ -n "$${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/50_luci-smartdns) && rm -f /etc/uci-defaults/50_luci-smartdns
	exit 0
}
endef

# call BuildPackage - OpenWrt buildroot signature

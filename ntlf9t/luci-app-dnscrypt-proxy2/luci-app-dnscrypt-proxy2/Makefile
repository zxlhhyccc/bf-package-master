#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-dnscrypt-proxy2
PKG_VERSION:=2.1.4
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=peter-tank

PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_minisign

LUCI_TITLE:=DNSCrypt Proxy LuCI interface
LUCI_PKGARCH:=all
LUCI_DEPENDS:= \
	+dnscrypt-proxy2-full +wget-ssl \
	+PACKAGE_$(PKG_NAME)_INCLUDE_minisign:minisign

define Package/$(PKG_NAME)/config
select PACKAGE_luci-lib-ipkg if PACKAGE_$(PKG_NAME)

config PACKAGE_$(PKG_NAME)_INCLUDE_minisign
	bool "Include minisign for customized offline resolvers list self-sign."
	default n

endef

define Package/$(PKG_NAME)/description
	LuCI Support for dnscrypt-proxy2.
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/dnscrypt-proxy
/etc/config/public-resolvers
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh

if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/dnscrypt-proxy ) && rm -f /etc/uci-defaults/dnscrypt-proxy
	chmod 755 /etc/init.d/dnscrypt-proxy >/dev/null 2>&1
	#/etc/init.d/dnscrypt-proxy enable >/dev/null 2>&1

	uci -q batch <<-EOF >/dev/null
		delete firewall.dnscrypt-proxy
		set firewall.dnscrypt-proxy=include
		set firewall.dnscrypt-proxy.type=script
		set firewall.dnscrypt-proxy.path=/var/etc/dnscrypt-proxy.include
		set firewall.dnscrypt-proxy.reload=0
		commit firewall
EOF
fi
exit 0
endef

define Package/$(PKG_NAME)/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
    echo "Removing rc.d symlink for dnscrypt-proxy"
     /etc/init.d/dnscrypt-proxy disable
     /etc/init.d/dnscrypt-proxy stop
    echo "Removing firewall rule for dnscrypt-proxy"
	  uci -q batch <<-EOF >/dev/null
		delete firewall.dnscrypt-proxy
		commit firewall
EOF
fi
exit 0
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

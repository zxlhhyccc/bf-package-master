#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI for Zerotier
LUCI_DEPENDS:=+zerotier +luci-compat
LUCI_PKGARCH:=all
PKG_VERSION:=1.2.0
PKG_RELEASE:=1

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-zerotier-lua/prerm
#!/bin/sh

/etc/init.d/luci_zerotier enable
/etc/init.d/luci_zerotier disable
/etc/init.d/luci_zerotier stop
exit 0
endef

define Package/luci-app-zerotier-lua/conffiles
/etc/config/zerotier
endef

# call BuildPackage - OpenWrt buildroot signature

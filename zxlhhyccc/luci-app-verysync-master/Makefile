# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Verysync
LUCI_DEPENDS:=+verysync +libc +curl +wget-ssl
LUCI_PKGARCH:=all
PKG_VERSION:=1.8
PKG_RELEASE:=1

define Package/$(PKG_NAME)/conffiles
/etc/config/verysync
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/$(PKG_NAME)/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/verysync stop
fi
exit 0
endef

# call BuildPackage - OpenWrt buildroot signature

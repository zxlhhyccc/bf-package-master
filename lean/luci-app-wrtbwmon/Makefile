# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for Wrtbwmon
LUCI_DEPENDS:=+luci +wrtbwmon
LUCI_PKGARCH:=all

PKG_LICENSE:=Apache-2.0
PKG_MAINTAINER:=Peter Bailey <peter.eldridge.bailey+wrtbwmon@gmail.com>

PKG_NAME:=luci-app-wrtbwmon
PKG_VERSION:=1.0
PKG_RELEASE:=8

URL:=https://github.com/Kiougar/luci-wrtbwmon

define Package/luci-app-wrtbwmon/conffiles
/etc/config/wrtbwmon
endef

include $(TOPDIR)/feeds/luci/luci.mk

define Package/luci-app-wrtbwmon/postinst
#!/bin/sh
#__remove_luci_cache__
rm -rf /tmp/luci*
endef

# call BuildPackage - OpenWrt buildroot signature

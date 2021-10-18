# Copyright (C) 2020 Gyj1109
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for syncthing
LUCI_DEPENDS:=+syncthing-master
LUCI_PKGARCH:=all
PKG_RELEASE:=$(COMMITCOUNT)

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

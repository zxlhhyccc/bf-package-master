# Copyright (C) 2016 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

LUCI_TITLE:=LuCI support for IPSec VPN Server (IKEv1 with PSK and Xauth)
LUCI_DEPENDS:=+strongswan +kmod-tun \
  +PACKAGE_strongswan:strongswan-mod-kernel-libipsec \
  +PACKAGE_strongswan:strongswan-mod-xauth-generic \
  +(PACKAGE_strongswan-mod-kdf||PACKAGE_strongswan-mod-openssl||PACKAGE_strongswan-mod-wolfssl):strongswan-minimal
LUCI_PKGARCH:=all
PKG_VERSION:=1.0
PKG_RELEASE:=11

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

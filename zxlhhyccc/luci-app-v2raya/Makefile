include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-v2raya
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_LICENSE:=AGPL-3.0-only
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

LUCI_TITLE:=LuCI support for v2rayA
LUCI_PKGARCH:=all
LUCI_DEPENDS:=+v2raya +lua +libuci-lua

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

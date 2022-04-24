#
# Copyright (C) 2010-2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_SOURCE_URL:=https://github.com/OpenVPN/easy-rsa.git
PKG_SOURCE_VERSION:=f06871cf0325c0e6fe340f82d45bf2f165a8e7e5
PKG_MIRROR_HASH:=2015ceb6b1e5ea42b94ce43624addc84394a6ec0c636ff9b88a79d510e7029cd

PKG_NAME:=openvpn-easy-rsa
PKG_VERSION:=3.1.0-rc1
PKG_RELEASE:=44
PKG_LICENSE:=GPL-2.0

PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_SOURCE_PROTO:=git

include $(INCLUDE_DIR)/package.mk

define Package/openvpn-easy-rsa-whisky
  TITLE:=CLI utility to build and manage a PKI CA.
  SECTION:=net
  CATEGORY:=Network
  URL:=http://openvpn.net
  SUBMENU:=VPN
  DEPENDS:=+openssl-util
  PKGARCH:=all
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/openvpn-easy-rsa-whisky/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/easyrsa3/easyrsa $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/easy-rsa/x509-types
	$(INSTALL_DATA) ./files/vars $(1)/etc/easy-rsa/vars
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/easyrsa3/openssl-easyrsa.cnf $(1)/etc/easy-rsa/openssl-easyrsa.cnf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/easyrsa3/x509-types/* $(1)/etc/easy-rsa/x509-types/
endef

$(eval $(call BuildPackage,openvpn-easy-rsa-whisky))

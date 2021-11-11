# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2014-2018 Jian Chang <aa65535@live.com>
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=openwrt_chinadns
PKG_VERSION:=1.3.3
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/aa65535/ChinaDNS.git
PKG_SOURCE_VERSION:=00616680114011553881760e843b77a3519e8fbf
PKG_SOURCE_SUBDIR:=ChinaDNS-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)
PKG_SOURCE:=ChinaDNS-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.xz

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jian Chang <aa65535@live.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)/ChinaDNS-$(PKG_VERSION)-$(PKG_SOURCE_VERSION)

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)/Default
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=IP Addresses and Names
	TITLE:=Protect yourself against DNS poisoning in China.
	URL:=https://github.com/shadowsocks/ChinaDNS
endef

define Package/$(PKG_NAME)
  $(call Package/$(PKG_NAME)/Default)
endef

define Package/$(PKG_NAME)/description
A DNS forwarder that ignores incorrect(you knew it) responses.
endef

define Package/$(PKG_NAME)/conffiles
/usr/share/chinadns/chnroute.txt
/usr/share/chinadns/iplist.txt
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/chinadns $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/chinadns.init $(1)/etc/init.d/chinadns
	$(INSTALL_DIR) $(1)/usr/share/chinadns
	$(CP) $(PKG_INSTALL_DIR)/usr/share/chnroute.txt $(1)/usr/share/chinadns/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/iplist.txt $(1)/usr/share/chinadns/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

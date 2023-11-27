#
# Copyright (C) 2021 CTCGFW Project-OpenWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dnsforwarder
PKG_VERSION:=6.5.3
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/lifenjoiner/dnsforwarder.git
PKG_SOURCE_DATE:=2023-11-25
PKG_SOURCE_VERSION:=e6ac595bc39ec674ce1b10ef58f3e77f5af48e20
PKG_MIRROR_HASH:=57fbaee2f8578d3d6a2a07afa8732dee71ef34af5103f18228755b22515e2f58

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Dennis <openwrt@tossp.com>

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_BUILD_FLAGS:=gc-sections lto

include $(INCLUDE_DIR)/package.mk

define Package/dnsforwarder/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A simple DNS forwarder
  URL:=https://github.com/holmium/dnsforwarder
  DEPENDS:=+coreutils +coreutils-base64 +dnsmasq-full +libpthread +wget-ssl
endef

define Package/dnsforwarder/Default/description
  Forwarding queries to customized domains (and their subdomains) to specified servers
  over a specified protocol (UDP or TCP). non-standard ports are supported.
endef

define Package/dnsforwarder/description
$(call Package/dnsforwarder/Default/description)
endef

define Package/dnsforwarder-acc/description
$(call Package/dnsforwarder/Default/description)
endef

define Package/dnsforwarder
  $(call Package/dnsforwarder/Default)
endef

define Package/dnsforwarder-acc
  $(call Package/dnsforwarder/Default)
endef

CONFIGURE_ARGS+= --enable-downloader=wget

TARGET_LDFLAGS += -Wl,--as-needed

define Package/dnsforwarder/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnsforwarder $(1)/usr/bin/dnsforwarder

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/etc/config/dnsforwarder $(1)/etc/config/dnsforwarder
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/etc/init.d/dnsforwarder $(1)/etc/init.d/dnsforwarder

	$(INSTALL_DIR) $(1)/etc/dnsforwarder
	$(INSTALL_CONF) files/etc/dnsforwarder/gfw.txt $(1)/etc/dnsforwarder/gfw.txt
	$(INSTALL_DIR) $(1)/usr/share/dnsforwarder
	$(INSTALL_BIN) files/usr/share/dnsforwarder/gfwlist.sh $(1)/usr/share/dnsforwarder/gfwlist.sh
endef

define Package/dnsforwarder-acc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dnsforwarder $(1)/usr/bin/dnsforwarder

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) acc-files/etc/config/dnsforwarder $(1)/etc/config/dnsforwarder
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) acc-files/etc/init.d/dnsforwarder $(1)/etc/init.d/dnsforwarder

	$(INSTALL_DIR) $(1)/etc/dnsforwarder
	$(INSTALL_CONF) acc-files/etc/dnsforwarder/gfw.txt $(1)/etc/dnsforwarder/gfw.txt
	$(INSTALL_DIR) $(1)/usr/share/dnsforwarder
	$(INSTALL_BIN) acc-files/usr/share/dnsforwarder/gfwlist.sh $(1)/usr/share/dnsforwarder/gfwlist.sh
endef

$(eval $(call BuildPackage,dnsforwarder))
$(eval $(call BuildPackage,dnsforwarder-acc))

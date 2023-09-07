#
# Copyright (c) 2018-2023 Nick Peng (pymumu@gmail.com)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2023.43
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=8befd9d5d2a84785cbf6296b02aae89a65311a91
PKG_MIRROR_HASH:=70f6ce433e4751e1b83cd4739d9bfaaec43c6b9f9733c09683252087b54635c4

PKG_MAINTAINER:=Nick Peng <pymumu@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_VARS += VER=$(PKG_VERSION)
MAKE_PATH:=src

define Package/smartdns
  SECTION:=net
  CATEGORY:=Network
  TITLE:=smartdns server
  DEPENDS:=+libpthread +libopenssl
  URL:=https://www.github.com/pymumu/smartdns/
endef

define Package/smartdns/description
SmartDNS is a local DNS server which accepts DNS query requests from local network clients,
gets DNS query results from multiple upstream DNS servers concurrently, and returns the fastest IP to clients.
Unlike dnsmasq's all-servers, smartdns returns the fastest IP, and encrypt DNS queries with DoT or DoH. 
endef

define Package/smartdns/conffiles
/etc/config/smartdns
/etc/smartdns/address.conf
/etc/smartdns/blacklist-ip.conf
/etc/smartdns/custom.conf
/etc/smartdns/anti-ad-smartdns.conf
/etc/smartdns/blacklist-chnroute.conf
/etc/smartdns/smartdns-domains.china.conf
/etc/smartdns/whitelist-chnroute.conf
/etc/smartdns/domain-block.list
/etc/smartdns/domain-forwarding.list
endef

define Package/smartdns/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d $(1)/usr/share/smartdns
	$(INSTALL_DIR) $(1)/etc/smartdns $(1)/etc/smartdns/domain-set $(1)/etc/smartdns/conf.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(1)/usr/sbin/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/package/openwrt/files/etc/init.d/smartdns $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/address.conf $(1)/etc/smartdns/address.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-block.list $(1)/etc/smartdns/domain-block.list
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-forwarding.list $(1)/etc/smartdns/domain-forwarding.list
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/blacklist-ip.conf $(1)/etc/smartdns/blacklist-ip.conf
	$(INSTALL_CONF) $(CURDIR)/conf/custom.conf $(1)/etc/smartdns/custom.conf
	$(INSTALL_CONF) $(CURDIR)/conf/smartdns.conf $(1)/etc/config/smartdns
	$(INSTALL_CONF) $(CURDIR)/conf/gfwlist.conf $(1)/etc/smartdns/domain-set/gfwlist.conf
	$(INSTALL_CONF) $(CURDIR)/conf/ipv4list.list $(1)/etc/smartdns/domain-set/ipv4list.list
	$(INSTALL_CONF) $(CURDIR)/conf/whitelist-chnroute.conf $(1)/etc/smartdns/whitelist-chnroute.conf
	$(INSTALL_CONF) $(CURDIR)/conf/blacklist-chnroute.conf $(1)/etc/smartdns/blacklist-chnroute.conf
	$(INSTALL_CONF) $(CURDIR)/conf/anti-ad-smartdns.conf $(1)/etc/smartdns/domain-set/anti-ad-smartdns.conf
	$(INSTALL_CONF) $(CURDIR)/conf/anti-ad-smartdns.conf $(1)/etc/smartdns/smartdns-domains.china.conf
	$(INSTALL_CONF) $(CURDIR)/conf/cnlist.conf $(1)/etc/smartdns/domain-set/cnlist.conf
	$(INSTALL_BIN) $(CURDIR)/conf/update-china-list.sh $(1)/usr/share/smartdns/update-china-list.sh
endef

$(eval $(call BuildPackage,smartdns))

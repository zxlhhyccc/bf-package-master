#
# Copyright (C) 2018-2023 Ruilin Peng (Nick) <pymumu@gmail.com>.
#
# smartdns is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# smartdns is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2023.41
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=c21be04632ff0657092af55e26679a8b47ed1ff7
PKG_MIRROR_HASH:=087947b0a1fc33c8c47d7ab0e2eb2baf38c9ab020b8a56af5141e6a881c5206c

PKG_MAINTAINER:=Nick Peng <pymumu@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_PATH:=src
MAKE_VARS += VER=$(PKG_VERSION)

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
Unlike dnsmasq's all-servers, smartdns returns the fastest IP. 
endef

define Package/smartdns/conffiles
/etc/config/smartdns
/etc/smartdns/address.conf
/etc/smartdns/blacklist-ip.conf
/etc/smartdns/custom.conf
/etc/smartdns/domain-block.list
/etc/smartdns/domain-forwarding.list
/etc/smartdns/anti-ad-smartdns.conf
/etc/smartdns/blacklist-chnroute.conf
/etc/smartdns/smartdns-domains.china.conf
/etc/smartdns/whitelist-chnroute.conf
endef

define Package/smartdns/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d $(1)/etc/smartdns $(1)/usr/share/smartdns
	$(INSTALL_DIR) $(1)/etc/smartdns/conf.d $(1)/etc/smartdns/domain-set
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(1)/usr/sbin/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/package/openwrt/files/etc/init.d/smartdns $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/address.conf $(1)/etc/smartdns/address.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-block.list $(1)/etc/smartdns/domain-block.list
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-forwarding.list $(1)/etc/smartdns/domain-forwarding.list
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/blacklist-ip.conf $(1)/etc/smartdns/blacklist-ip.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/custom.conf $(1)/etc/smartdns/custom.conf-opkg
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/files/etc/config/smartdns $(1)/etc/config/smartdns-opkg
	$(INSTALL_CONF) $(CURDIR)/conf/custom.conf $(1)/etc/smartdns/custom.conf
	$(INSTALL_CONF) $(CURDIR)/conf/smartdns.conf $(1)/etc/config/smartdns
	$(INSTALL_CONF) $(CURDIR)/conf/gfwlist.conf $(1)/etc/smartdns/gfwlist.conf
	$(INSTALL_CONF) $(CURDIR)/conf/whitelist-chnroute.conf $(1)/etc/smartdns/whitelist-chnroute.conf
	$(INSTALL_CONF) $(CURDIR)/conf/blacklist-chnroute.conf $(1)/etc/smartdns/blacklist-chnroute.conf
	$(INSTALL_CONF) $(CURDIR)/conf/anti-ad-smartdns.conf $(1)/etc/smartdns/anti-ad-smartdns.conf
	$(INSTALL_CONF) $(CURDIR)/conf/anti-ad-smartdns.conf $(1)/etc/smartdns/smartdns-domains.china.conf
	$(INSTALL_CONF) $(CURDIR)/conf/cnlist.conf $(1)/etc/smartdns/cnlist.conf
	$(INSTALL_BIN) $(CURDIR)/conf/update-china-list.sh $(1)/usr/share/smartdns/update-china-list.sh
endef

$(eval $(call BuildPackage,smartdns))

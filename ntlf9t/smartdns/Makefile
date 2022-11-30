#
# Copyright (C) 2018-2022 Ruilin Peng (Nick) <pymumu@gmail.com>.
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
PKG_VERSION:=1.2022.38.1
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=c8734d603bd73caa86a6091775e5f64260445027
PKG_MIRROR_HASH:=6b4492c63f0fd06eb683b06fdb1e8b964e8eed993833e533ee4df3527d3a7cf0

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
get DNS query results from multiple upstream DNS servers concurrently, and returns the fastest IP to clients.
Unlike dnsmasq's all-servers, smartdns returns the fastest IP. 
endef

define Package/smartdns/conffiles
/etc/config/smartdns
/etc/smartdns/address.conf
/etc/smartdns/anti-ad-smartdns.conf
/etc/smartdns/blacklist-chnroute.conf
/etc/smartdns/blacklist-ip.conf
/etc/smartdns/custom.conf
/etc/smartdns/smartdns-domains.china.conf
/etc/smartdns/whitelist-chnroute.conf
endef

define Package/smartdns/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d $(1)/etc/smartdns $(1)/usr/share/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(1)/usr/sbin/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/package/openwrt/files/etc/init.d/smartdns $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/address.conf $(1)/etc/smartdns/address.conf
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

define Package/smartdns/postinst
#!/bin/sh
	/etc/init.d/smartdns enable >/dev/null 2>&1
	enable=$$(uci get smartdns.@smartdns[0].enabled 2>/dev/null)
	if [ "$$enable" == "1" ]; then
		/etc/init.d/smartdns reload
	fi
	rm -f /tmp/luci-indexcache
	rm -f /tmp/luci-modulecache/*
exit 0
endef

define Package/smartdns/prerm
#!/bin/sh

if [ -z "$${IPKG_INSTROOT}" ]; then
     /etc/init.d/smartdns disable
     /etc/init.d/smartdns stop
uci -q batch <<-EOF >/dev/null 2>&1
	delete ucitrack.@smartdns[-1]
	commit ucitrack
EOF
fi
exit 0
endef

$(eval $(call BuildPackage,smartdns))

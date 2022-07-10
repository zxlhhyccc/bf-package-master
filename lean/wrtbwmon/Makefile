#
# Copyright (C) 2006-2011 Xmlad.com
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wrtbwmon
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Peter Bailey <peter.eldridge.bailey+wrtbwmon@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/wrtbwmon
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A Traffic Usage Monitor
	SUBMENU:=Tools
	PKGARCH:=all
	DEPENDS:=+libc
	URL:=https://github.com/pyrovski/wrtbwmon
endef

define Package/wrtbwmon/description
wrtbwmon was designed to track bandwidth consumption on home routers. It accomplishes this with iptables rules, which means you don't need to run an extra process just to track bandwidth. wrtbwmon conveniently tracks bandwidth consumption on a per-IP address basis, so you can easily determine which user/device is the culprit.
endef

define Package/wrtbwmon/postinst
#!/bin/sh
#__check_rule_exsit__

cat $${IPKG_INSTROOT}/etc/firewall.user | grep '/etc/init.d/wrtbwmon restart' >/dev/null 2>&1

#__create_when_missing__
if [ "$?" != "0" ]; then
    echo "#__restart_wrtbwmon__" >> $${IPKG_INSTROOT}/etc/firewall.user
    echo "/etc/init.d/wrtbwmon restart" >> $${IPKG_INSTROOT}/etc/firewall.user
fi
endef

define Package/wrtbwmon/postrm
#!/bin/sh
#__restore_fw_user__
cat $${IPKG_INSTROOT}/etc/firewall.user > /tmp/fw.user
rm -f /etc/firewall.user
cat /tmp/fw.user | sed -e '/#__restart_wrtbwmon__/d' >> $${IPKG_INSTROOT}/etc/firewall.user
cat $${IPKG_INSTROOT}/etc/firewall.user > /tmp/fw.user
rm -f /etc/firewall.user
cat /tmp/fw.user | sed -e '/\/etc\/init.d\/wrtbwmon restart/d' >> $${IPKG_INSTROOT}/etc/firewall.user
rm -f /tmp/fw.user
endef

define Build/Compile
endef

define Package/wrtbwmon/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/share/wrtbwmon
	$(INSTALL_BIN) ./net/usr/sbin/* $(1)/usr/sbin/
	$(INSTALL_BIN) ./net/usr/share/wrtbwmon/* $(1)/usr/share/wrtbwmon/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./net/etc/init.d/wrtbwmon $(1)/etc/init.d/wrtbwmon
endef

$(eval $(call BuildPackage,wrtbwmon))

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-koolddns
PKG_VERSION:=20170517
PKG_RELEASE:=2
PKG_MAINTAINER:=fw867

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
#PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	PKGARCH:=all
	TITLE:=luci for koolddns
        DEPENDS:=+koolddns
endef

define Package/$(PKG_NAME)/description
    A luci app for koolddns, forked from koolshare Lede X64. Thanks to fw867.
endef

define Package/$(PKG_NAME)/preinst
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-koolddns ]; then
		( . /etc/uci-defaults/luci-koolddns ) && rm -f /etc/uci-defaults/luci-koolddns
	fi
	rm -rf /tmp/luci-indexcache
fi
exit 0
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/etc/uci-defaults/luci-koolddns $(1)/etc/uci-defaults/luci-koolddns
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/i18n/*.lmo $(1)/usr/lib/lua/luci/i18n/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/koolddns
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/koolddns/*.lua $(1)/usr/lib/lua/luci/model/cbi/koolddns/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/koolddns
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/view/koolddns/* $(1)/usr/lib/lua/luci/view/koolddns/
	
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./files/usr/share/rpcd/acl.d/* $(1)/usr/share/rpcd/acl.d

endef

$(eval $(call BuildPackage,$(PKG_NAME)))
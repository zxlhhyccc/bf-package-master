include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-control-arpbind
PKG_VERSION:=20170518
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
#PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	PKGARCH:=all
	TITLE:=luci for arpbind
        DEPENDS:=+ip-full
endef

define Package/$(PKG_NAME)/description
    A luci app for arpbind, forked from koolshare Lede X64. Thanks to fw867.
endef

define Package/$(PKG_NAME)/preinst
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	if [ -f /etc/uci-defaults/luci-arpbind ]; then
		( . /etc/uci-defaults/luci-arpbind ) && rm -f /etc/uci-defaults/luci-arpbind
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
	$(INSTALL_BIN) ./files/etc/uci-defaults/luci-arpbind $(1)/etc/uci-defaults/luci-arpbind
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/arpbind $(1)/etc/init.d/arpbind
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/i18n/*.lmo $(1)/usr/lib/lua/luci/i18n/
	
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/arpbind.lua $(1)/usr/lib/lua/luci/model/cbi/
	
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DATA) ./files/etc/hotplug.d/iface/* $(1)/etc/hotplug.d/iface/

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_BIN) ./files/usr/share/rpcd/acl.d/*.json $(1)/usr/share/rpcd/acl.d/

endef

$(eval $(call BuildPackage,$(PKG_NAME)))

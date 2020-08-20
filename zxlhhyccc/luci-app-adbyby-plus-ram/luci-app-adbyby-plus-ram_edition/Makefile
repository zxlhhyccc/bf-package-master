include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-adbyby-plus-ram_edition
PKG_VERSION:=2.7
PKG_RELEASE:=9

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=LuCI
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=LuCI support for Adbyby
  DEPENDS:=+adbyby-ram_edition +wget +ipset +coreutils +coreutils-nohup +dnsmasq-full +ca-certificates
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
	Luci Support for Adbyby.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/po/zh_Hans/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh
[ -n "${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/luci-app-adbyby) && rm -f /etc/uci-defaults/luci-app-adbyby
	exit 0
}
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./luasrc/model/cbi/*.lua $(1)/usr/lib/lua/luci/model/cbi/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/adbyby
	$(INSTALL_DATA) ./luasrc/view/adbyby/*.htm $(1)/usr/lib/lua/luci/view/adbyby/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/adbyby.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./root/etc/config/adbyby $(1)/etc/config/adbyby
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/adbyby $(1)/etc/init.d/adbyby
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/luci-app-adbyby $(1)/etc/uci-defaults/luci-app-adbyby
	$(INSTALL_DIR) $(1)/usr/share/adbyby
	$(INSTALL_BIN) ./root/usr/share/adbyby/*.sh $(1)/usr/share/adbyby/
	$(INSTALL_BIN) ./root/usr/share/adbyby/gen_include $(1)/usr/share/adbyby/gen_include
	$(INSTALL_DATA) ./root/usr/share/adbyby/*.conf $(1)/usr/share/adbyby/
	$(INSTALL_DATA) ./root/usr/share/adbyby/dnsmasq.esc $(1)/usr/share/adbyby/dnsmasq.esc
	$(INSTALL_DATA) ./root/usr/share/adbyby/rules.txt $(1)/usr/share/adbyby/rules.txt
	$(INSTALL_DATA) ./root/usr/share/adbyby/adbyby_local $(1)/usr/share/adbyby/adbyby_local
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/usr/share/rpcd/acl.d/luci-app-adbyby-plus-ram_edition.json $(1)/usr/share/rpcd/acl.d/luci-app-adbyby-plus-ram_edition.json
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

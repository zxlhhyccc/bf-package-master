include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-control-vlmcsd
PKG_VERSION:=1.1
PKG_RELEASE:=2

PKG_MAINTAINER:=fuyumi <280604399@qq.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-control-vlmcsd
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI app for openwrt-vlmcsd
	DEPENDS:=+control-vlmcsd +luci-compat
	PKGARCH:=all
	MAINTAINER:=fuyumi
endef

define Package/luci-app-control-vlmcsd/description
	This package contains LuCI configuration pages for openwrt-vlmcsd.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/po/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Compile
endef

define Package/luci-app-control-vlmcsd/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	( . /etc/uci-defaults/luci-app-vlmcsd ) && rm -f /etc/uci-defaults/luci-app-vlmcsd
fi
exit 0
endef

define Package/luci-app-control-vlmcsd/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./luasrc/controller/* $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/vlmcsd
	$(INSTALL_DATA) ./luasrc/model/cbi/vlmcsd/* $(1)/usr/lib/lua/luci/model/cbi/vlmcsd/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/vlmcsd
	$(INSTALL_DATA) ./luasrc/view/vlmcsd/* $(1)/usr/lib/lua/luci/view/vlmcsd/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/vlmcsd.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./root/etc/config/* $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./root/etc/init.d/* $(1)/etc/init.d/
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./root/etc/uci-defaults/* $(1)/etc/uci-defaults/
	$(INSTALL_DATA) ./root/etc/vlmcsd.ini $(1)/etc/
	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(INSTALL_DATA) ./root/acl.d/* $(1)/usr/share/rpcd/acl.d/
endef

$(eval $(call BuildPackage,luci-app-control-vlmcsd))

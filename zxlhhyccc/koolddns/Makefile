include $(TOPDIR)/rules.mk

PKG_NAME:=koolddns
PKG_VERSION:=20170916
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
#PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=net
	TITLE:=ddns for aliddns and dnspod and cloudxns
        DEPENDS:=+curl +openssl-util +bind-dig +drill
endef

define Package/$(PKG_NAME)/description
    A aliddns and dnspod app for lede 
endef

define Package/$(PKG_NAME)/preinst
endef

define Package/$(PKG_NAME)/postinst

endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Package/$(PKG_NAME)/conffiles
/etc/config/koolddns
endef

define Package/$(PKG_NAME)/install

	$(INSTALL_DIR) $(1)/etc/ssl/certs
	$(INSTALL_DATA) ./files/etc/ssl/certs/VeriSign.cer $(1)/etc/ssl/certs/VeriSign.cer

	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/etc/hotplug.d/iface/96-koolddns $(1)/etc/hotplug.d/iface/96-koolddns
	
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/etc/config/koolddns $(1)/etc/config/
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/* $(1)/etc/init.d/
	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/aliddns $(1)/usr/bin/klaliddns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dnspod $(1)/usr/bin/kldnspod
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cloudxns $(1)/usr/bin/klcloudxns

endef

$(eval $(call BuildPackage,$(PKG_NAME)))
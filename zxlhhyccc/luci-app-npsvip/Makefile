#
# Copyright (C) 2008-2014 The LuCI Team <luci@lists.subsignal.org>
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-npsvip
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-npsvip
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI support for Npc
	DEPENDS:=
	MAINTAINER:=panda-mute <wxuzju@gmail.com>
endef

define Build/Compile
endef

define Package/luci-app-npsvip/conffiles
/etc/config/npsvip
/etc/conf/npsvip.conf
endef

define Package/luci-app-npsvip/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	cp -pR ./luasrc/* $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/
	cp -pR ./root/* $(1)/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./po/zh-cn/npsvip.po $(1)/usr/lib/lua/luci/i18n/npsvip.zh-cn.lmo
	po2lmo ./po/zh_Hans/npsvip.po $(1)/usr/lib/lua/luci/i18n/npsvip.zh-cn.lmo
	$(INSTALL_DIR) $(1)/usr/bin

ifeq ($(ARCH),aarch64)
	$(INSTALL_BIN) ./bin/arm64 $(1)/usr/bin/npsvip

else ifeq ($(ARCH),arm)
	$(INSTALL_BIN) ./bin/armv7 $(1)/usr/bin/npsvip

else ifeq ($(BOARD),bcm53xx)
	$(INSTALL_BIN) ./bin/armv6 $(1)/usr/bin/npsvip
else ifeq ($(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE)))),)
	$(INSTALL_BIN) ./bin/armv5 $(1)/usr/bin/npsvip

else ifeq ($(BOARD),kirkwood)
	$(INSTALL_BIN) ./bin/armv5 $(1)/usr/bin/npsvip

else ifeq ($(ARCH),i386)
	$(INSTALL_BIN) ./bin/i386 $(1)/usr/bin/npsvip

else ifeq ($(ARCH),mips)
	$(INSTALL_BIN) ./bin/mips $(1)/usr/bin/npsvip
	
else ifeq ($(ARCH),mipsel)
	$(INSTALL_BIN) ./bin/mipsle $(1)/usr/bin/npsvip

else ifeq ($(ARCH),x86_64)
	$(INSTALL_BIN) ./bin/x86_64 $(1)/usr/bin/npsvip
endif
endef

define Package/luci-app-npsvip/postinst
[ -n "$${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/luci-npsvip) && rm -f /etc/uci-defaults/luci-npsvip
	exit 0
}
endef

$(eval $(call BuildPackage,luci-app-npsvip))

# call BuildPackage - OpenWrt buildroot signature

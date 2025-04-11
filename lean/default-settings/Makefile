# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2021 Lean <coolsnowwolf@gmail.com>
# Copyright (C) 2021-2024 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=default-settings
PKG_VERSION:=1.1
PKG_RELEASE:=29

PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/default-settings
  SECTION:=luci
  CATEGORY:=LuCI
  TITLE:=LuCI support for Default Settings
  PKGARCH:=all
  DEPENDS:=+luci
endef

define Package/default-settings-chn
  $(Package/default-settings)
  TITLE+= (Optimize for CHN users)
  DEPENDS:=+default-settings +@LUCI_LANG_zh_Hans +luci-i18n-base-zh-cn
endef

define Package/default-settings-ipq807x
  $(Package/default-settings)
  TITLE+= (Optimize for CHN users)
  DEPENDS:=@TARGET_qualcommax \
		   +default-settings
endef

define Build/Compile
endef

define Package/default-settings/install
	#$(INSTALL_DIR) $(1)/etc
	#$(INSTALL_DATA) ./files/openwrt_banner $(1)/etc/openwrt_banner

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zzz-default-settings $(1)/etc/uci-defaults/99-default-settings
endef

define Package/default-settings-chn/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zzz-default-settings-chinese $(1)/etc/uci-defaults/99-default-settings-chinese

	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	po2lmo ./i18n/default.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/default.zh-cn.lmo
	po2lmo ./i18n/more.zh_Hans.po $(1)/usr/lib/lua/luci/i18n/more.zh-cn.lmo
	po2lmo ./i18n/other_zh.po $(1)/usr/lib/lua/luci/i18n/other.zh-cn.lmo
endef

define Package/default-settings-ipq807x/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/zzz-default-settings-ipq807x $(1)/etc/uci-defaults/99-default-settings-ipq807x
endef

$(eval $(call BuildPackage,default-settings))
$(eval $(call BuildPackage,default-settings-chn))
$(eval $(call BuildPackage,default-settings-ipq807x))

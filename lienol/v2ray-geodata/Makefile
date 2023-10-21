# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-geodata
PKG_RELEASE:=1

PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

include $(INCLUDE_DIR)/package.mk

GEOIP_VER:=202310190056
GEOIP_FILE:=geoip.dat.$(GEOIP_VER)
define Download/geoip
#  URL:=https://github.com/v2fly/geoip/releases/download/$(GEOIP_VER)/
#  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$(GEOIP_VER)/
#  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download
#  URL_FILE:=geoip.dat
  URL:=https://github.com/Loyalsoldier/geoip/releases/latest/download
  URL_FILE:=geoip-only-cn-private.dat
  FILE:=$(GEOIP_FILE)
  HASH:=8eaf47ded831e50519680276e3ef519ad075ece4ae8a5b234f806d6a0a002e24
endef

GEOSITE_VER:=202310202208
#GEOSITE_FILE:=dlc.dat.$(GEOSITE_VER)
GEOSITE_FILE:=geosite.dat.$(GEOSITE_VER)
define Download/geosite
#  URL:=https://github.com/v2fly/domain-list-community/releases/download/$(GEOSITE_VER)/
#  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/$(GEOIP_VER)/
  URL:=https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download
#  URL_FILE:=dlc.dat
  URL_FILE:=geosite.dat
  FILE:=$(GEOSITE_FILE)
  HASH:=c206d28f3050202c23a95a12fc6f14d25fc2c7546632f18d133ec0378b038846
endef

GEOSITE_IRAN_VER:=202310161455
GEOSITE_IRAN_FILE:=iran.dat.$(GEOSITE_IRAN_VER)
define Download/geosite-ir
#  URL:=https://github.com/bootmortis/iran-hosted-domains/releases/download/$(GEOSITE_IRAN_VER)/
  URL:=https://github.com/bootmortis/iran-hosted-domains/releases/latest/download/iran.dat
  URL_FILE:=iran.dat
  FILE:=$(GEOSITE_IRAN_FILE)
  HASH:=8ec881422249b4cf78b110385d5b8531a8ed069a54894c5bce6f335b6eed2a71
endef

define Package/v2ray-geodata/template
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://www.v2fly.org
  PKGARCH:=all
endef

define Package/v2ray-geoip
  $(call Package/v2ray-geodata/template)
  TITLE:=GeoIP List for V2Ray
  VERSION:=$(GEOIP_VER)-$(PKG_RELEASE)
  LICENSE:=CC-BY-SA-4.0
endef

define Package/v2ray-geosite
  $(call Package/v2ray-geodata/template)
  TITLE:=Geosite List for V2Ray
  VERSION:=$(GEOSITE_VER)-$(PKG_RELEASE)
  LICENSE:=MIT
endef

define Package/v2ray-geosite-ir
  $(call Package/v2ray-geodata/template)
  TITLE:=Iran Geosite List for V2Ray
  PROVIDES:=xray-geosite-ir
  VERSION:=$(GEOSITE_IRAN_VER)-$(PKG_RELEASE)
  LICENSE:=MIT
endef

define Build/Prepare
	$(call Build/Prepare/Default)
ifneq ($(CONFIG_PACKAGE_v2ray-geoip),)
	$(call Download,geoip)
endif
ifneq ($(CONFIG_PACKAGE_v2ray-geosite),)
	$(call Download,geosite)
endif
ifneq ($(CONFIG_PACKAGE_v2ray-geosite-ir),)
	$(call Download,geosite-ir)
endif
endef

define Build/Compile
endef

define Package/v2ray-geoip/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(DL_DIR)/$(GEOIP_FILE) $(1)/usr/share/v2ray/geoip.dat
endef

define Package/v2ray-geosite/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray
	$(INSTALL_DATA) $(DL_DIR)/$(GEOSITE_FILE) $(1)/usr/share/v2ray/geosite.dat
endef

define Package/v2ray-geosite-ir/install
	$(INSTALL_DIR) $(1)/usr/share/v2ray $(1)/usr/share/xray
	$(INSTALL_DATA) $(DL_DIR)/$(GEOSITE_IRAN_FILE) $(1)/usr/share/v2ray/iran.dat
	$(LN) ../v2ray/iran.dat $(1)/usr/share/xray/iran.dat
endef

$(eval $(call BuildPackage,v2ray-geoip))
$(eval $(call BuildPackage,v2ray-geosite))
$(eval $(call BuildPackage,v2ray-geosite-ir))

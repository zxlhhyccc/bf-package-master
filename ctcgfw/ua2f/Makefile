# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2021 Zxilly <zhouxinyu1001@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=ua2f
PKG_VERSION:=3.8
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Zxilly/UA2F.git
PKG_SOURCE_DATE:=2022-04-21
PKG_SOURCE_VERSION:=52e88acf8ff818457a59dd9a059d584939e4a0ec
PKG_MIRROR_HASH:=8d1379ae40a6ac6391acb07b7421b65cf64ef83ab42311606cb9d7b5fcc97383

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILE:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ua2f
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Change User-Agent to Fwords
  URL:=https://github.com/Zxilly/UA2F
  DEPENDS:=+ipset +iptables-mod-conntrack-extra +iptables-mod-nfqueue \
    +libnetfilter-conntrack +libnetfilter-queue
endef

define Package/ua2f/description
  Change User-agent to Fwords to prevent being checked by Dr.Com.
endef

EXTRA_LDFLAGS += -lmnl -lnetfilter_queue -lipset

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(EXTRA_LDFLAGS) \
		$(PKG_BUILD_DIR)/ua2f.c -o $(PKG_BUILD_DIR)/ua2f
endef

define Package/ua2f/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ua2f $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/ua2f.config $(1)/etc/config/ua2f
	$(INSTALL_BIN) ./files/ua2f.init $(1)/etc/init.d/ua2f
	$(INSTALL_BIN) ./files/ua2f.uci $(1)/etc/uci-defaults/80-ua2f
endef

define Package/ua2f/postinst
#!/bin/sh

# check if we are on real system
[ -n "$${IPKG_INSTROOT}" ] || {
	(. /etc/uci-defaults/80-ua2f) && rm -f /etc/uci-defaults/80-ua2f
	exit 0
}
endef

$(eval $(call BuildPackage,ua2f))

# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2020 Lean <coolsnowwolf@gmail.com>
# Copyright (C) 2021-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=autocore-ports
PKG_FLAGS:=nonshared
PKG_RELEASE:=42

PKG_CONFIG_DEPENDS:= \
	CONFIG_TARGET_bcm27xx \
	CONFIG_TARGET_bcm53xx \
	CONFIG_TARGET_x86

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/target.mk

define Package/autocore-ports
  TITLE:=auto core loadbalance script.
  DEPENDS:=@(aarch64||arm||i386||i686||x86_64) \
    +TARGET_bcm27xx:bcm27xx-utils \
    +TARGET_bcm53xx:nvram \
    +TARGET_x86:ethtool \
    +TARGET_x86:lm-sensors
endef

define Build/Compile
endef

define Package/autocore-ports/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/generic/10_system.js $(1)/etc/rpcd_10_system.js
	$(CP) ./files/generic/luci $(1)/etc/rpcd_luci

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/generic/60-autocore-reload-rpcd $(1)/etc/uci-defaults/
	$(INSTALL_BIN) ./files/generic/090-cover-index_files $(1)/etc/uci-defaults/

ifneq ($(filter i386 i686 x86_64, $(ARCH)),)
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/x86/autocore $(1)/etc/init.d/
endif

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/generic/cpuinfo $(1)/sbin/
ifneq ($(filter ipq% mediatek% qualcommax%, $(TARGETID)),)
	$(INSTALL_BIN) ./files/arm/tempinfo $(1)/sbin/
endif

	$(INSTALL_DIR) $(1)/usr/share/rpcd/acl.d
	$(CP) ./files/generic/luci-mod-status-autocore.json $(1)/usr/share/rpcd/acl.d/
endef

$(eval $(call BuildPackage,autocore-ports))

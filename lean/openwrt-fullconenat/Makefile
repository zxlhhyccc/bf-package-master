#
# Copyright (C) 2018 Chion Tang <tech@chionlab.moe>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=fullconenat
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/llccd/netfilter-full-cone-nat.git
PKG_SOURCE_DATE:=2025-09-21
PKG_SOURCE_VERSION:=4254b6801416b510930a0efa0563e9233381a15e
PKG_MIRROR_HASH:=1078b2dba5d00ab862d45bbc1f5e4ffc3744446c8f55c1a8a5e56bd9be4f4146

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Chion Tang <tech@chionlab.moe>

include $(INCLUDE_DIR)/package.mk

define Package/iptables-mod-fullconenat
  SUBMENU:=Firewall
  SECTION:=net
  CATEGORY:=Network
  TITLE:=FULLCONENAT iptables extension
  DEPENDS:=+libxtables +kmod-ipt-fullconenat
endef

define Package/ip6tables-mod-fullconenat
  SUBMENU:=Firewall
  SECTION:=net
  CATEGORY:=Network
  TITLE:=FULLCONENAT ip6tables extension
  DEPENDS:=ip6tables +libxtables +kmod-nf-nat6 +kmod-ipt-fullconenat +ip6tables-mod-nat
endef

define KernelPackage/ipt-fullconenat
  SUBMENU:=Netfilter Extensions
  TITLE:=FULLCONENAT netfilter module
  DEPENDS:=+kmod-nf-ipt +kmod-nf-nat
  KCONFIG:= \
	CONFIG_NF_CONNTRACK_EVENTS=y \
	CONFIG_NF_CONNTRACK_CHAIN_EVENTS=y
  FILES:=$(PKG_BUILD_DIR)/xt_FULLCONENAT.ko
  AUTOLOAD:=$(call AutoProbe,xt_FULLCONENAT)
endef

include $(INCLUDE_DIR)/kernel-defaults.mk

define Build/Compile
	+$(KERNEL_MAKE) $(PKG_JOBS) \
		M="$(PKG_BUILD_DIR)" \
		EXTRA_CFLAGS="$(BUILDFLAGS)" \
		modules
	$(call Build/Compile/Default)
endef

define Package/iptables-mod-fullconenat/install
	$(INSTALL_DIR) $(1)/usr/lib/iptables
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libipt_FULLCONENAT.so $(1)/usr/lib/iptables
endef

define Package/ip6tables-mod-fullconenat/install
	$(INSTALL_DIR) $(1)/usr/lib/iptables
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/libip6t_FULLCONENAT.so $(1)/usr/lib/iptables
endef

$(eval $(call KernelPackage,ipt-fullconenat))
$(eval $(call BuildPackage,iptables-mod-fullconenat))
$(eval $(call BuildPackage,ip6tables-mod-fullconenat))


# SPDX-Identifier-License: GPL-3.0-only
#
# Copyright (C) 2022 Lean <coolsnowwolf@gmail.com>
# Copyright (C) 2019-2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-turboacc
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0-only
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org> & Lean <coolsnowwolf@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_BBRPLUS \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_NANQINLANG \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_TSUNAMI \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_TSUNAMIO \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_DNSFORWARDER \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_DNSPROXY \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_ADGUARDHOME \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_OFFLOADING \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_CM \
	CONFIG_PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_DRV

LUCI_TITLE:=LuCI support for Flow Offload / Shortcut-FE
LUCI_DEPENDS:=+PACKAGE_$(PKG_NAME)_INCLUDE_PDNSD:pdnsd-alt \
	+PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA:kmod-tcp-bbr \
	+PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_BBRPLUS:kmod-tcp-bbrplus \
	+PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_NANQINLANG:kmod-tcp-nanqinlang \
	+PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_TSUNAMI:kmod-tcp-tsunami \
	+PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_TSUNAMIO:kmod-tcp-tsunamio \
	+PACKAGE_$(PKG_NAME)_INCLUDE_DNSFORWARDER:dnsforwarder-acc \
	+PACKAGE_$(PKG_NAME)_INCLUDE_DNSPROXY:dnsproxy-neo \
	+PACKAGE_$(PKG_NAME)_INCLUDE_ADGUARDHOME:AdGuardHome \
	+PACKAGE_$(PKG_NAME)_INCLUDE_OFFLOADING:kmod-ipt-offload \
	+PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE:kmod-fast-classifier \
	+PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_CM:kmod-shortcut-fe-cm \
	+PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_DRV:kmod-shortcut-fe-drv
LUCI_PKGARCH:=all

define Package/$(PKG_NAME)/config
config PACKAGE_$(PKG_NAME)_INCLUDE_OFFLOADING
	bool "Include Flow Offload"
	default y if !(TARGET_x86||TARGET_ipq60xx||TARGET_ipq806x||TARGET_ipq807x||TARGET_qualcommax)

config PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE
	bool "Include Shortcut-FE"
	depends on PACKAGE_$(PKG_NAME)_INCLUDE_OFFLOADING=n
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_CM
	bool "Include Shortcut-FE CM"
	depends on PACKAGE_$(PKG_NAME)_INCLUDE_OFFLOADING=n
	default y if !(TARGET_ipq60xx||TARGET_ipq806x||TARGET_ipq807x||TARGET_qualcommax)

config PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_DRV
	bool "Include Shortcut-FE ECM"
	depends on PACKAGE_$(PKG_NAME)_INCLUDE_OFFLOADING=n
	depends on PACKAGE_$(PKG_NAME)_INCLUDE_SHORTCUT_FE_CM=n
	depends on (TARGET_ipq60xx||TARGET_ipq806x||TARGET_ipq807x)
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA
	bool "Include BBR CCA"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_BBRPLUS
	bool "Include BBR CCA BBRPLUS"
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_NANQINLANG
	bool "Include BBR CCA NANQINLANG"
	depends on !LINUX_6_6
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_TSUNAMI
	bool "Include BBR CCA TSUNAMI"
	depends on !LINUX_6_6
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_BBR_CCA_TSUNAMIO
	bool "Include BBR CCA TSUNAMIO"
	depends on !(LINUX_6_1||LINUX_6_6)
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_PDNSD
	bool "Include Pdnsd"
	default y

config PACKAGE_$(PKG_NAME)_INCLUDE_DNSFORWARDER
	bool "Include DNSForwarder"
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_DNSPROXY
	bool "Include DNSProxy"
	default n

config PACKAGE_$(PKG_NAME)_INCLUDE_ADGUARDHOME
	bool "Include AdGuardHome"
	default n
endef

include $(TOPDIR)/feeds/luci/luci.mk

# call BuildPackage - OpenWrt buildroot signature

#
# Copyright (C) 2014-2015 KyleRicardo
#
# Copyright (C) 2021 ImmortalWrt
# <https://immortalwrt.org>
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mentohust
PKG_VERSION:=0.3.1
PKG_RELEASE:=3

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk.git
PKG_SOURCE_DATE:=2022-05-10
PKG_SOURCE_VERSION:=d1a8a3a77275c89884d0fa1e95fd404287431f13
PKG_MIRROR_HASH:=a85e36397b11d0cdd8d24523f0379e75ac56b091d42323c5ae5ac4081453098c

PKG_BUILD_PARALLEL:=1

MAKE_PATH:=src

include $(INCLUDE_DIR)/package.mk

define Package/mentohust
	SECTION:=net
	CATEGORY:=Network
	TITLE:=A Ruijie Client Daemon
	URL:=https://github.com/KyleRicardo/MentoHUST-OpenWrt-ipk
	SUBMENU:=Campus Network
	DEPENDS:=+libpcap
endef

define Package/mentohust/description
	A Ruijie Client Daemon, most usually used in China collages.
endef

define Package/mentohust/conffiles
/etc/mentohust.conf
endef

define Package/mentohust/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/mentohust $(1)/usr/sbin/mentohust
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/src/mentohust.conf $(1)/etc/mentohust.conf
endef

$(eval $(call BuildPackage,mentohust))

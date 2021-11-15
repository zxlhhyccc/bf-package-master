#
# Copyright (C) 2017-2021
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qbittorrent
PKG_VERSION:=4.4.0rc1
PKG_RELEASE=$(COMMITCOUNT)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=qBittorrent-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/qbittorrent/qBittorrent.git
PKG_SOURCE_DATE:=2021-11-10
PKG_SOURCE_VERSION:=b45248bf99ef00ce314d210c1cb9ebe5fe247cc0
PKG_MIRROR_HASH:=bda0293bf53931014880829da6a02d9fd064bbc78ec82ff7d76e86bc54e69d9f

# PKG_BUILD_DIR:=$(BUILD_DIR)/qBittorrent-release-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:qbittorrent:qbittorrent

PKG_BUILD_DEPENDS:=qttools boost

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/qbittorrent
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=BitTorrent
	DEPENDS:=+libgcc +libstdcpp \
		+libtorrent-rasterbar \
		+libopenssl \
		+libqt5core \
		+libqt5network \
		+libqt5xml \
		+libqt5sql \
		+libqt5sql-sqlite \
		+zlib
	TITLE:=bittorrent client programmed in C++ / Qt
	URL:=https://www.qbittorrent.org/
	PROVIDES:=qBittorrent
endef

define Package/qbittorrent/description
  qBittorrent is a bittorrent client programmed in C++ / Qt that uses
  libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.
  It aims to be a good alternative to all other bittorrent clients out
  there. qBittorrent is fast, stable and provides unicode support as
  well as many features.
endef

CONFIGURE_ARGS += \
	--disable-gui \
	--enable-stacktrace=no \
	--with-boost=$(STAGING_DIR)/usr

MAKE_VARS += \
	INSTALL_ROOT="$(PKG_INSTALL_DIR)"

TARGET_CFLAGS += -std=c++17 -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Package/qbittorrent/conffiles
/etc/config/qbittorrent
endef

define Package/qbittorrent/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) ./files/qbittorrent.init $(1)/etc/init.d/qbittorrent
	$(INSTALL_CONF) ./files/qbittorrent.conf $(1)/etc/config/qbittorrent

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qbittorrent-nox $(1)/usr/bin
endef

$(eval $(call BuildPackage,qbittorrent))

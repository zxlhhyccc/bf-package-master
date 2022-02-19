#
# Copyright (C) 2017-2021
#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qbittorrent
PKG_VERSION:=4.4.1
PKG_RELEASE=1

PKG_SOURCE:=qBittorrent-release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/qbittorrent/qBittorrent/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=144a609514a7b516e65c4a4e32e49529b5e3949a713daf86332cd95867c991ba

PKG_BUILD_DIR:=$(BUILD_DIR)/qBittorrent-release-$(PKG_VERSION)

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:qbittorrent:qbittorrent

PKG_BUILD_DEPENDS:=qttools/host boost

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/qbittorrent
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=BitTorrent
  DEPENDS:=+USE_GLIBC:librt +USE_GLIBC:libpthread +libc +libgcc +libstdcpp \
	+libtorrent-rasterbar +libopenssl +libqt6core +libqt6network \
	+libqt6sql +libqt6sql-sqlite +libqt6xml +zlib
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

CMAKE_OPTIONS += \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_CXX_STANDARD=17 \
	-DQT6=ON \
	-DSTACKTRACE=OFF \
	-DWEBUI=ON \
	-DGUI=OFF \
	-DVERBOSE_CONFIGURE=ON \
	-DQT_ADDITIONAL_PACKAGES_PREFIX_PATH=$(STAGING_DIR_HOSTPKG)

# The pcre2 is compiled with support for mips16
ifdef CONFIG_USE_MIPS16
  TARGET_CFLAGS += -minterlink-mips16
endif

# Support the glibc
ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -ldl -lrt -lpthread
endif

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -flto

# The pentium-mmx with lto will build failed on qt6
ifeq ($(ARCH),i386)
  ifneq ($(findstring pentium-mmx,$(CONFIG_CPU_TYPE)),)
    TARGET_CFLAGS := $(filter-out -flto,$(TARGET_CFLAGS))
    TARGET_LDFLAGS := $(filter-out -flto,$(TARGET_LDFLAGS))
  endif
endif

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

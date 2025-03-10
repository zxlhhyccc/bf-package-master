# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2023 bishuiwuhen

include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent-rasterbar
PKG_VERSION:=2.0.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/arvidn/libtorrent/releases/download/v$(PKG_VERSION)
PKG_HASH:=f0db58580f4f29ade6cc40fa4ba80e2c9a70c90265cd77332d3cdec37ecf1e6d

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:libtorrent:libtorrent

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS+=no-mips16

PYTHON3_PKG_BUILD:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/libtorrent-rasterbar
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C++ bittorrent library by Rasterbar Software
  URL:=https://www.libtorrent.org
  DEPENDS:=+boost +boost-system +libatomic +libgcc +libopenssl +libstdcpp
  ABI_VERSION:=2.0
endef

define Package/python3-libtorrent
  $(call Package/libtorrent-rasterbar)
  TITLE:=Python bindings for libtorrent-rasterbar
  DEPENDS+=+PACKAGE_python3-libtorrent:boost-python3 +libtorrent-rasterbar
endef

define Package/libtorrent-rasterbar/description
  Libtorrent is a feature complete C++ bittorrent implementation focusing on
  efficiency and scalability. It runs on embedded devices as well as desktops.
  It boasts a well documented library interface that is easy to use.
endef

define Package/python3-libtorrent/description
  Building the libtorrent python bindings will produce a shared library which
  is a python module that can be imported in a python program.
endef

TARGET_CFLAGS += $(FPIC) -ffunction-sections -fdata-sections -flto=auto -fno-fat-lto-objects
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -flto=auto -fuse-linker-plugin

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-Ddeprecated-functions=OFF \
	-Dlogging=OFF \
	-DCMAKE_CXX_STANDARD=17 \
	-Dpython-bindings=$(if $(CONFIG_PACKAGE_python3-libtorrent),ON,OFF)

define Build/InstallDev
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)
endef

define Package/libtorrent-rasterbar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.so.* $(1)/usr/lib
endef

define Package/python3-libtorrent/install
	$(INSTALL_DIR) $(1)$(PYTHON3_PKG_DIR)
	$(CP) $(PKG_INSTALL_DIR)$(PYTHON3_PKG_DIR)/* $(1)$(PYTHON3_PKG_DIR)
endef

$(eval $(call BuildPackage,libtorrent-rasterbar))
$(eval $(call BuildPackage,python3-libtorrent))

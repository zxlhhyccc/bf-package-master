# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2023 bishuiwuhen

include $(TOPDIR)/rules.mk

PKG_NAME:=qttools
PKG_BASE:=6.9
PKG_BUGFIX:=1
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
		http://download.qt.io/official_releases/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://master.qt.io/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules
PKG_HASH:=90c4a562f4ccfd043fd99f34c600853e0b5ba9babc6ec616c0f306f2ce3f4b4c

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)

PKG_HOST_ONLY:=1
HOST_BUILD_PARALLEL:=1
HOST_BUILD_DEPENDS:=qtbase/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/qttools
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt6
  TITLE:=qttools
  URL:=http://qt-project.org
  BUILDONLY:=1
endef

CMAKE_HOST_OPTIONS += \
	-DCMAKE_DISABLE_FIND_PACKAGE_Clang=TRUE \
	-DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=TRUE \
	-DINPUT_assistant=no \
	-DINPUT_clang=no \
	-DINPUT_clangcpp=no \
	-DINPUT_designer=no \
	-DINPUT_distancefieldgenerator=no \
	-DINPUT_kmap2qmap=no \
	-DINPUT_pixeltool=no \
	-DINPUT_qdbus=no \
	-DINPUT_qev=no \
	-DINPUT_qtattributionsscanner=no \
	-DINPUT_qtdiag=no \
	-DINPUT_qtplugininfo=no

$(eval $(call BuildPackage,qttools))
$(eval $(call HostBuild))

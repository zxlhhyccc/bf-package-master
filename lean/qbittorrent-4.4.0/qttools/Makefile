#
# Copyright (C) 2019-2021
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qttools
PKG_BASE:=6.4
PKG_BUGFIX:=1
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
		http://download.qt.io/official_releases/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://master.qt.io/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules
PKG_HASH:=9e20562c6b04c21fbdb4ed89e59226169ffeaafaab8f45f7d81ea49b0e4b0933

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)

PKG_HOST_ONLY:=1
HOST_BUILD_PARALLEL:=1
HOST_BUILD_DEPENDS:=qtbase/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/package.mk

define Package/qttools
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt6
  TITLE:=qttools
  URL:=http://qt-project.org
  BUILDONLY:=1
endef

HOST_CONFIGURE_ARGS = \
	-no-feature-assistant \
	-no-feature-clang \
	-no-feature-clangcpp \
	-no-feature-designer \
	-no-feature-distancefieldgenerator \
	-no-feature-kmap2qmap \
	-no-feature-pixeltool \
	-no-feature-qdbus \
	-no-feature-qev \
	-no-feature-qtattributionsscanner \
	-no-feature-qtdiag \
	-no-feature-qtplugininfo \
	-- \
	-DCMAKE_DISABLE_FIND_PACKAGE_Clang=TRUE \
	-DCMAKE_DISABLE_FIND_PACKAGE_WrapLibClang=TRUE

define Host/Configure
	cd $(HOST_BUILD_DIR) && $(STAGING_DIR_HOSTPKG)/bin/qt-configure-module . $(HOST_CONFIGURE_ARGS)
endef

$(eval $(call BuildPackage,qttools))
$(eval $(call HostBuild))

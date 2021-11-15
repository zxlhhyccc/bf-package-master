#
# Copyright (C) 2019-2021
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qttools
PKG_BASE:=5.15
PKG_BUGFIX:=2
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
		http://download.qt.io/official_releases/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://master.qt.io/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules
PKG_HASH:=c189d0ce1ff7c739db9a3ace52ac3e24cb8fd6dbf234e49f075249b38f43c1cc

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=qtbase

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt5
  TITLE:=qttools
  URL:=http://qt-project.org
  BUILDONLY:=1
endef

CONFIGURE_ARGS = \
	-no-feature-assistant \
	-no-feature-designer \
	-no-feature-distancefieldgenerator \
	-no-feature-kmap2qmap \
	-no-feature-macdeployqt \
	-no-feature-makeqpf \
	-no-feature-pixeltool \
	-no-feature-qdbus \
	-no-feature-qev \
	-no-feature-qtattributionsscanner \
	-no-feature-qtpaths \
	-no-feature-qtplugininfo \
	-no-feature-qtdiag \
	-no-feature-windeployqt \
	-no-feature-winrtrunner

define Build/Configure
	cd $(PKG_BUILD_DIR) && qmake -o Makefile qttools.pro -- $(CONFIGURE_ARGS)
endef

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)
endef

define Build/InstallDev
	$(MAKE) -C $(PKG_BUILD_DIR) install
endef

$(eval $(call BuildPackage,$(PKG_NAME)))

#
# Copyright (C) 2019-2021
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qtbase
PKG_BASE:=6.2
PKG_BUGFIX:=3
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
		http://download.qt.io/official_releases/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://master.qt.io/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules
PKG_HASH:=34d6d0072e197241463c417ad72610c3d44e2efd6062868e9a95283103d75df4

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=qtbase/host

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_CPE_ID:=cpe:/a:qt:qt

CMAKE_INSTALL:=1

# Force to use strip instead of sstrip
STRIP:=$(TARGET_CROSS)strip $(call qstrip,$(CONFIG_STRIP_ARGS))

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/qtbase/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt6
  TITLE:=qtbase
  URL:=http://qt-project.org
  DEPENDS:=+libc +libgcc +libstdcpp +USE_GLIBC:librt +USE_GLIBC:libpthread \
	@!LINUX_2_6_36 @!(ARM&&CPU_32v4)
endef

define Package/qtbase/description
  This package provides the Qt6 libraries.

  Qt is a cross-platform application development framework for desktop, embedded and mobile.
  Supported Platforms include Linux, OS X, Windows, VxWorks, QNX, Android, iOS, BlackBerry,
  Sailfish OS and others.

  Qt is not a programming language on its own. It is a framework written in C++.

  This package provides the following run-time libraries:
  - core
  - network
  - xml
  - sql
endef

define Package/qtbase
  $(call Package/qtbase/Default)
  HIDDEN:=1
endef

define Package/qtbase/config
menu "qtbase"
	comment "Qtbase Libraries"

	$(foreach lib,$(QTBASE_LIBS),
	config PACKAGE_libqt6$(lib)
		tristate "libqt6$(lib)"
		default m if ALL
		help
		$(Package/libqt6$(lib)/description)
	)
endmenu
endef

#LBITS = $(shell $(TARGET_CC) -dM -E - </dev/null | grep -q "__LP64__" && echo 64 || echo 32)
#
#ifeq ($(LBITS),64)
#    export USE_64=1
#endif

ifeq ($(CONFIG_CPU_TYPE),"xscale")
  TARGET_CFLAGS+= -mfloat-abi=softfp
endif

ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -ldl -lrt -lpthread
endif

TARGET_CFLAGS += $(FPIC) -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -flto

CMAKE_HOST_OPTIONS += \
	-DQT_FORCE_MIN_CMAKE_VERSION_FOR_BUILDING_QT=3.19 \
	-DCMAKE_STAGING_PREFIX=$(STAGING_DIR_HOSTPKG) \
	-DCMAKE_BUILD_TYPE=Release \
	-DFEATURE_optimize_size=ON \
	-DBUILD_SHARED_LIBS=OFF \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_dbus=OFF \
	-DFEATURE_gui=OFF \
	-DFEATURE_sql=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_zstd=OFF \
	-DINPUT_openssl=no

CMAKE_OPTIONS += \
	-DQT_FORCE_MIN_CMAKE_VERSION_FOR_BUILDING_QT=3.19 \
	-DQT_FORCE_MIN_CMAKE_VERSION_FOR_USING_QT=3.19 \
	-DCMAKE_SYSROOT=$(STAGING_DIR) \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DINSTALL_ARCHDATADIR=/usr/share/Qt6 \
	-DINSTALL_DATADIR=/usr/share/Qt6 \
	-DQT_HOST_PATH=$(STAGING_DIR_HOSTPKG) \
	-DQT_QMAKE_TARGET_MKSPEC=devices/linux-generic-g++ \
	-DQT_QMAKE_DEVICE_OPTIONS=CROSS_COMPILE="$(TARGET_CROSS);COMPILER_FLAGS=$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS);LINKER_FLAGS=$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=ON \
	-DFEATURE_optimize_size=ON \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
	-DCMAKE_SKIP_RPATH=TRUE \
	-DFEATURE_system_zlib=ON \
	-DFEATURE_cups=OFF \
	-DFEATURE_dbus=OFF \
	-DFEATURE_libudev=OFF \
	-DFEATURE_widgets=OFF \
	-DFEATURE_zstd=OFF \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_testlib=OFF \
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF \
	\
	-DFEATURE_system_doubleconversion=OFF \
	-DFEATURE_system_pcre2=ON \
	-DFEATURE_mimetype_database=ON \
	-DFEATURE_glib=OFF \
	-DFEATURE_icu=OFF \
	\
	-DFEATURE_gui=OFF \
	-DFEATURE_freetype=OFF \
	-DFEATURE_gbm=OFF \
	-DFEATURE_harfbuzz=OFF \
	-DFEATURE_jpeg=OFF \
	-DFEATURE_png=OFF \
	-DFEATURE_mtdev=OFF \
	-DINPUT_opengl=no \
	-DFEATURE_tslib=OFF \
	-DFEATURE_xcb=OFF \
	-DFEATURE_xcb_xlib=OFF \
	-DFEATURE_xkbcommon=OFF \
	\
	-DINPUT_openssl=runtime \
	-DFEATURE_libproxy=OFF \
	-DFEATURE_gssapi=OFF \
	\
	-DFEATURE_sql=ON \
	-DFEATURE_system_sqlite=OFF \
	-DFEATURE_sql_db2=OFF \
	-DFEATURE_sql_ibase=OFF \
	-DFEATURE_sql_mysql=OFF \
	-DFEATURE_sql_oci=OFF \
	-DFEATURE_sql_odbc=OFF \
	-DFEATURE_sql_psql=OFF \
	\
	-DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=OFF \
	-DLIBATOMIC_LIBS="-latomic"

define Package/qtbase/Default/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libQt6$(shell echo $(2) | sed -e 's/\b[[:alpha:]]/\u&/g').so* $(1)/usr/lib
endef

# 1: library short name
# 2: dependencies on other qtbase libraries (short name)
# 3: dependencies on other packages
define DefineQtbaseLibrary
  PKG_CONFIG_DEPENDS+=CONFIG_PACKAGE_libqt6$(1)
  QTBASE_LIBS+=$(1)

  define Package/libqt6$(1)
    $(call Package/qtbase/Default)
    TITLE+=$(1) library
    DEPENDS+=$(foreach lib,$(2),+libqt6$(lib)) $(3)
    ABI_VERSION:=6
    HIDDEN:=1
  endef

  define Package/libqt6$(1)/description
    This package contains the qtbase $(1) library.
  endef

  define Package/libqt6$(1)/install
    $(call Package/qtbase/Default/install,$$(1),$(1))
  endef
endef

$(eval $(call DefineQtbaseLibrary,core,,+libatomic +libpcre2-16 +zlib))
$(eval $(call DefineQtbaseLibrary,network,core,+libopenssl +zlib))
$(eval $(call DefineQtbaseLibrary,xml,core,))
$(eval $(call DefineQtbaseLibrary,sql,core,))

define Package/qtbase/Plugins/install
	$(INSTALL_DIR) $(1)/usr/share/Qt6/plugins/$(2)
	$(CP) $(PKG_INSTALL_DIR)/usr/share/Qt6/plugins/$(2)/lib$(3).so $(1)/usr/share/Qt6/plugins/$(2)
endef

# 1: plugin directory
# 2: plugin short name
# 3: so file name
# 4: dependencies on other qtbase libraries (short name)
# 5: dependencies on other packages
define DefineQtbasePlugin
  $(call DefineQtbaseLibrary,$(2),$(4),$(5))

  define Package/libqt6$(2)/install
    $(call Package/qtbase/Plugins/install,$$(1),$(1),$(3))
  endef
endef

$(eval $(call DefineQtbasePlugin,sqldrivers,sql-sqlite,qsqlite,core sql,+libpcre2-16 +zlib))

$(foreach lib,$(QTBASE_LIBS),$(eval $(call BuildPackage,libqt6$(lib))))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,qtbase))

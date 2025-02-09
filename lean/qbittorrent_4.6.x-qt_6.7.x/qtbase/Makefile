# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2017-2023 bishuiwuhen

include $(TOPDIR)/rules.mk

PKG_NAME:=qtbase
PKG_BASE:=6.8
PKG_BUGFIX:=2
PKG_VERSION:=$(PKG_BASE).$(PKG_BUGFIX)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= \
		http://download.qt.io/official_releases/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules \
		http://master.qt.io/archive/qt/$(PKG_BASE)/$(PKG_VERSION)/submodules
PKG_HASH:=012043ce6d411e6e8a91fdc4e05e6bedcfa10fcb1347d3c33908f7fdd10dfe05

HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-everywhere-src-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=qtbase/host

HOST_BUILD_PARALLEL:=1
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS+=no-mips16

PKG_LICENSE:=LGPL-3.0-only
PKG_LICENSE_FILES:=LICENSES/LGPL-3.0-only.txt
PKG_CPE_ID:=cpe:/a:qt:qt

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/qtbase/Default
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Qt6
  TITLE:=qtbase
  URL:=http://qt-project.org
  DEPENDS:=+libgcc +libstdcpp @!LINUX_2_6_36 @!(ARM&&CPU_32v4)
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

# Can be removed if glibc version> 2.34
ifdef CONFIG_USE_GLIBC
  TARGET_LDFLAGS += -ldl -lrt -lpthread
endif

TARGET_LDFLAGS += -Wl,--as-needed

CMAKE_SHARED_LDFLAGS:=$(filter-out -Wl$(comma)-Bsymbolic-functions,$(CMAKE_SHARED_LDFLAGS))

CMAKE_HOST_OPTIONS += \
	-DQT_FORCE_MIN_CMAKE_VERSION_FOR_BUILDING_QT=3.19 \
	-DCMAKE_BUILD_TYPE=Release \
	-DBUILD_SHARED_LIBS=OFF \
	-DFEATURE_concurrent=OFF \
	-DFEATURE_dbus=OFF \
	-DFEATURE_gui=OFF \
	-DFEATURE_optimize_size=ON \
	-DFEATURE_sql=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_zstd=OFF \
	-DFEATURE_glib=OFF \
	-DFEATURE_icu=OFF \
	-DFEATURE_brotli=OFF \
	-DFEATURE_androiddeployqt=OFF \
	-DFEATURE_macdeployqt=OFF \
	-DFEATURE_windeployqt=OFF \
	-DINPUT_libb2=no \
	-DINPUT_openssl=no \
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF

# The corelib will depend on openssl if openssl version >= 3.0. It is used in class QCryptographicHash.
# Disable `FEATURE_opensslv30` explicitly because we don't use it.
CMAKE_OPTIONS += \
	-DQT_FORCE_MIN_CMAKE_VERSION_FOR_BUILDING_QT=3.19 \
	-DQT_FORCE_MIN_CMAKE_VERSION_FOR_USING_QT=3.19 \
	-DINSTALL_ARCHDATADIR=/usr/share/Qt6 \
	-DINSTALL_DATADIR=/usr/share/Qt6 \
	-DQT_HOST_PATH=$(STAGING_DIR_HOSTPKG) \
	-DQT_QMAKE_TARGET_MKSPEC=devices/linux-generic-g++ \
	-DQT_QMAKE_DEVICE_OPTIONS=CROSS_COMPILE="$(TARGET_CROSS);COMPILER_FLAGS=$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS);LINKER_FLAGS=$(TARGET_LDFLAGS) $(EXTRA_LDFLAGS)" \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_BUILD_TYPE=Release \
	-DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON \
	-DCMAKE_SKIP_RPATH=TRUE \
	\
	-DFEATURE_concurrent=OFF \
	-DFEATURE_dbus=OFF \
	-DFEATURE_gui=OFF \
	-DFEATURE_libudev=OFF \
	-DFEATURE_optimize_size=ON \
	-DFEATURE_printsupport=OFF \
	-DFEATURE_testlib=OFF \
	-DFEATURE_thread=ON \
	-DFEATURE_widgets=OFF \
	-DFEATURE_zstd=OFF \
	-DFEATURE_system_zlib=ON \
	\
	-DINPUT_doubleconversion=qt \
	-DINPUT_pcre2=system \
	-DFEATURE_glib=OFF \
	-DFEATURE_icu=OFF \
	-DFEATURE_mimetype=ON \
	-DFEATURE_permissions=OFF \
	-DFEATURE_opensslv30=OFF \
	\
	-DFEATURE_network=ON \
	-DINPUT_openssl=linked \
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
	-DFEATURE_sql_mimer=OFF \
	\
	-DFEATURE_xml=ON \
	-DFEATURE_xkbcommon=OFF \
	\
	-DQT_BUILD_EXAMPLES=OFF \
	-DQT_BUILD_TESTS=OFF \
	-DQT_BUILD_TOOLS_WHEN_CROSSCOMPILING=OFF

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
$(eval $(call DefineQtbasePlugin,tls,network-tlsbackend-openssl,qopensslbackend,core network,+libopenssl +libpcre2-16 +zlib))

$(foreach lib,$(QTBASE_LIBS),$(eval $(call BuildPackage,libqt6$(lib))))
$(eval $(call HostBuild))
$(eval $(call BuildPackage,qtbase))

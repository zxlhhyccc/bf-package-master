#
# Copyright (C) 2007-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wxbase
PKG_VERSION:=3.0.5.1
PKG_RELEASE:=1

PKG_SOURCE:=wxGTK-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/wxWidgets/wxWidgets/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=bae4d9f289e33a05fb8553fcc580564d30efe6a882ff08e3d4e09ef01f5f6578

PKG_BUILD_DIR:=$(BUILD_DIR)/wxWidgets-$(PKG_VERSION)
PKG_CHECK_FORMAT_SECURITY:=0
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libwxbase
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Cross-platform C++ framework
  URL:=http://www.wxwidgets.org/
  DEPENDS:=+libexpat +libstdcpp +zlib +libpthread
endef

define Package/libwxbase/description
  wxBase contains most of the non-GUI classes from the wxWindows cross-
  -platform C++ framework. There are 2 categories: generally useful portable
  code (date/time handling, command line parsing, regular expression support)
  and wrappers for the OS objects (files, directories, sockets, threads,
  etc.) allowing you to write portable programs easily.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS+= \
	--enable-shared \
	--disable-rpath \
	--with-gnu-ld \
	--disable-gui \
	--disable-monolithic \
	--enable-plugins \
	--disable-universal \
	--disable-nanox \
	--disable-gtk2 \
	--disable-gpe \
	--enable-optimise \
	--disable-debug \
	--disable-stl \
	--disable-omf \
	--disable-debug_flag \
	--disable-mediactrl \
	--disable-debug_info \
	--disable-debug_gdb \
	--disable-debug_cntxt \
	--disable-mem_tracing \
	--disable-profile \
	--disable-no_rtti \
	--disable-no_exceptions \
	--disable-compat22 \
	--disable-compat24 \
	--enable-intl \
	--disable-backtrace \
	--enable-exceptions \
	--disable-sound \
	--enable-largefile \
	--enable-unicode \
	\
	--without-gtk \
	--without-motif \
	--without-mac \
	--without-cocoa \
	--without-wine \
	--without-msw \
	--without-pm \
	--without-mgl \
	--without-microwin \
	--without-x11 \
	--without-libpng \
	--without-libjpeg \
	--without-libtiff \
	--without-libxpm \
	--without-libmspack \
	--without-sdl \
	--without-gnomeprint \
	--without-opengl \
	--without-dmalloc \
	--with-regex="sys" \
	--with-zlib="sys" \
	--without-odbc \
	--with-expat="sys" \
	--without-gtk-prefix \
	--without-x \
	--without-libiconv-prefix \
	--without-sdl-prefix \
	--without-cppunit-prefix \
	--disable-precomp-headers

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wx-config $(1)/usr/bin/
	$(SED) "s,$(PKG_BUILD_DIR),$(STAGING_DIR)/usr,g" $(1)/usr/bin/wx-config
	$(SED) 's,-I$$$${includedir}/wx-3.0,-I$(STAGING_DIR)/usr/include/wx-3.0,g' $(1)/usr/bin/wx-config
	$(SED) 's,-I$$$${libdir}/wx/include,-I$(STAGING_DIR)/usr/lib/wx/include,g' $(1)/usr/bin/wx-config

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/wx-3.0 $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/wx $(1)/usr/lib/
endef

define Package/libwxbase/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwx_*.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libwxbase))

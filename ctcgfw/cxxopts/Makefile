#
# Copyright (C) 2021 ImmortalWrt
# (https://immortalwrt.org)
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=cxxopts
PKG_VERSION:=3.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/jarro2783/cxxopts/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=36f41fa2a46b3c1466613b63f3fa73dc24d912bc90d667147f1e43215a8c6d00

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=CN_SZTL <cnsztl@immortalwrt.org>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS+= -DCXXOPTS_ENABLE_INSTALL=ON \
	-DCXXOPTS_BUILD_EXAMPLES=OFF \
	-DCXXOPTS_BUILD_TESTS=OFF

define Package/cxxopts
  SECTION:=lib
  CATEGORY:=Libraries
  URL:=https:/github.com/jarro2783/cxxopts
  TITLE:=Lightweight C++ command line option parser
  DEPENDS:=+libc
  BUILDONLY:=1
endef

define Package/cxxopts/description
  This is a lightweight C++ option parser library, supporting the standard GNU style syntax for options.
endef

$(eval $(call BuildPackage,cxxopts))

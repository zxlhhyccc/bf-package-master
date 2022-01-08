# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=quickjspp
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ftk/quickjspp.git
PKG_SOURCE_DATE:=2021-12-17
PKG_SOURCE_VERSION:=03b980fd4af2f07c210b658270c897bbb687bac2
PKG_MIRROR_HASH:=ee255157038a3a1924cb4ccb6ce01460125ff297bd363d5f7b003ee89606445c

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/quickjspp
  SECTION:=lib
  CATEGORY:=Libraries
  URL:=https://github.com/ftk/quickjspp
  TITLE:=QuickJS wrapper for C++
  DEPENDS:=+libatomic +libpthread
  BUILDONLY:=1
endef

define Package/quickjspp/description
  QuickJSPP is QuickJS wrapper for C++. It allows you to easily embed
  Javascript engine into your program.
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DCMAKE_EXE_LINKER_FLAGS="-latomic" \
	-DCMAKE_REQUIRED_LIBRARIES=stdc++fs

$(eval $(call BuildPackage,quickjspp))

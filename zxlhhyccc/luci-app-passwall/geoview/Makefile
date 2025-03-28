include $(TOPDIR)/rules.mk

PKG_NAME:=geoview
PKG_VERSION:=0.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/snowie2000/geoview/tar.gz/$(PKG_VERSION)?
PKG_HASH:=06d3dc1e67de452086a6e8ee477cbfab0f73ff19effeefdf652be0fb62e55348

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=snowie2000

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

PKG_CONFIG_DEPENDS:= \
	CONFIG_GEOVIEW_COMPRESS_GOPROXY \
	CONFIG_GEOVIEW_COMPRESS_UPX

GO_PKG:=github.com/snowie2000/geoview
GO_PKG_BUILD_PKG:=$(GO_PKG)

GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/geoview
  TITLE:=A geofile toolkit
  URL:=https://github.com/snowie2000/geoview
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  DEPENDS+= $(GO_ARCH_DEPENDS)
endef

define Package/geoview/description
  geoview is a handy tool to extract useful information from geo* files.
endef

define Package/geoview/config
	config GEOVIEW_COMPRESS_GOPROXY
		bool "Compiling with GOPROXY proxy"
		default n

	config GEOVIEW_COMPRESS_UPX
		bool "Compress executable files with UPX"
		depends on !mips64
		default n
endef

ifeq ($(CONFIG_GEOVIEW_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_GEOVIEW_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/geoview
endif
endef

define Package/geoview/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/geoview $(1)/usr/bin/
endef

$(eval $(call GoBinPackage,geoview))
$(eval $(call BuildPackage,geoview))

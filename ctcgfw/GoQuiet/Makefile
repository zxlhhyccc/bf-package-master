#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=GoQuiet
PKG_VERSION:=1.2.2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cbeuw/GoQuiet.git
PKG_SOURCE_VERSION:=013cdfdf72000dcd4691799c37a0cf960ab4c82f
PKG_MIRROR_HASH:=c9c97463e5286e8ad10de5e86512b98f60672235c47cfd9696188a16496fc56c

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_GQ_CLIENT_COMPRESS_UPX \
	CONFIG_GQ_SERVER_COMPRESS_UPX

GO_PKG:=github.com/cbeuw/GoQuiet
GO_PKG_BUILD_PKG:=github.com/cbeuw/GoQuiet/cmd/...
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/GoQuiet/template
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GoQuiet
  DEPENDS:=$(GO_ARCH_DEPENDS) +libpthread
  URL:=https://github.com/cbeuw/GoQuiet
  SUBMENU:=Web Servers/Proxies
endef

define Package/gq-client
  $(call Package/GoQuiet/template)
  TITLE+= (client)
endef

define Package/gq-server
  $(call Package/GoQuiet/template)
  TITLE+= (server)
endef

Package/gq-client/description = $(Package/GoQuiet/description/template)
Package/gq-server/description = $(Package/GoQuiet/description/template)

define Package/gq-client/config
config GQ_CLIENT_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

define Package/gq-server/config
config GQ_SERVER_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

GO_PKG_BUILD_VARS += GO111MODULE=auto

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_GQ_CLIENT_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/gq-client
endif
ifeq ($(CONFIG_GQ_SERVER_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/gq-server
endif
endef

define Package/GoQuiet/install/template
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin/$(2)
endef

Package/gq-client/install = $(call Package/GoQuiet/install/template,$(1),gq-client)
Package/gq-server/install = $(call Package/GoQuiet/install/template,$(1),gq-server)

$(eval $(call GoBinPackage,gq-client))
$(eval $(call GoBinPackage,gq-server))
$(eval $(call BuildPackage,gq-client))
$(eval $(call BuildPackage,gq-server))

# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=filebrowser
PKG_VERSION:=2.34.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/filebrowser/filebrowser.git
PKG_SOURCE_VERSION:=70d59ec03ed3fa9c99cf9151037367a534559145
PKG_MIRROR_HASH:=36d419b4d89797c030b01c215341cec54e0122071b70ecb1923ce2ee1542dd08

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host node/host node-pnpm/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

PKG_CONFIG_DEPENDS:= \
	CONFIG_FILEBROWSER_COMPRESS_GOPROXY \
	CONFIG_FILEBROWSER_COMPRESS_UPX

GO_PKG:=github.com/filebrowser/filebrowser/v2
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/version.CommitSHA=$(PKG_VERSION) \
	$(GO_PKG)/version.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/filebrowser/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Web File Browser
  DEPENDS:=$(GO_ARCH_DEPENDS)
  URL:=https://github.com/filebrowser/filebrowser
endef

define Package/filebrowser/Default/description
  filebrowser provides a file managing interface within a specified directory
  and it can be used to upload, delete, preview, rename and edit your files.
  It allows the creation of multiple users and each user can have its own directory.
  It can be used as a standalone app or as a middleware.
endef

define Package/filebrowser/description
$(call Package/filebrowser/Default/description)
endef

define Package/filebrowser-neo/description
$(call Package/filebrowser/Default/description)
endef

define Package/filebrowser
  $(call Package/filebrowser/Default)
endef

define Package/filebrowser-neo
  $(call Package/filebrowser/Default)
endef

define Package/filebrowser/config
config FILEBROWSER_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config FILEBROWSER_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_FILEBROWSER_COMPRESS_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.io
endif

define Build/Prepare
	$(call Build/Prepare/Default)
endef

define Build/Compile
	( \
		export PNPM_HOME="$(PKG_BUILD_DIR)/frontend" ; \
		pushd "$(PKG_BUILD_DIR)/frontend" ; \
		pnpm install --frozen-lockfile ; \
		pnpm run build ; \
		popd ; \
		$(call GoPackage/Build/Compile) ; \
	)
ifeq ($(CONFIG_FILEBROWSER_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/filebrowser
endif
endef

define Package/filebrowser/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/filebrowser.config $(1)/etc/config/filebrowser
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/filebrowser.init $(1)/etc/init.d/filebrowser
endef

define Package/filebrowser-neo/install
	$(call GoPackage/Package/Install/Bin,$(1))
endef

$(eval $(call GoBinPackage,filebrowser))
$(eval $(call BuildPackage,filebrowser))
$(eval $(call BuildPackage,filebrowser-neo))

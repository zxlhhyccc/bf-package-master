#
# Copyright (C) 2021 ImmortalWrt
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=control-filebrowser
PKG_VERSION:=2.17.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=bf303c536ae000036d810639cc13fcf4e082e0cb
PKG_SOURCE_URL:=https://github.com/filebrowser/filebrowser
PKG_MIRROR_HASH:=8506a48fc98fbda963f5809bc783bd5f359f9ae7012174bd46ef31e1aa24b91f

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=CN_SZTL <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host node/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_FILEBROWSER_COMPRESS_GOPROXY \
	CONFIG_FILEBROWSER_COMPRESS_UPX

GO_PKG:=github.com/filebrowser/filebrowser
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/v2/version.CommitSHA=$(PKG_SOURCE_VERSION) \
	$(GO_PKG)/v2/version.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/control-filebrowser
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Web File Browser
  URL:=https://github.com/filebrowser/filebrowser
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/control-filebrowser/description
  filebrowser provides a file managing interface within a specified directory
  and it can be used to upload, delete, preview, rename and edit your files.
  It allows the creation of multiple users and each user can have its own directory.
  It can be used as a standalone app or as a middleware.
endef

define Package/control-filebrowser/config
config FILEBROWSER_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config FILEBROWSER_COMPRESS_UPX
	bool "Compress executable files with UPX"
	default y
endef

ifeq ($(CONFIG_FILEBROWSER_COMPRESS_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.io
endif

define Build/Compile
( \
  cd $(PKG_BUILD_DIR)/frontend ; \
  npm ci; \
  npm run lint ; \
  npm run build ; \
  $(call GoPackage/Build/Compile) ; \
)
ifeq ($(CONFIG_FILEBROWSER_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/filebrowser
endif
endef

define Package/control-filebrowser/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/filebrowser $(1)/usr/bin/filebrowser
endef

$(eval $(call GoBinPackage,control-filebrowser))
$(eval $(call BuildPackage,control-filebrowser))

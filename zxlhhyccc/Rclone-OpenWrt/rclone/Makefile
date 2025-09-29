# SPDX-Identifier-License: GPL-3.0-or-later
#
# Copyright (C) 2019 Elon Huang <elonhhuang@gmail.com>
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=rclone
PKG_VERSION:=1.71.1
PKG_RELEASE:=1

# PKG_SOURCE_PROTO:=git
# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
# PKG_SOURCE_URL:=https://github.com/rclone/rclone.git
# PKG_SOURCE_DATE:=2023-05-05
# PKG_SOURCE_VERSION:=f226f2dfb1eefdfd0fa044dd319ba81443d9eece
#PKG_MIRROR_HASH:=78c75b0a976067a061797f158e2a766e442d43cc5963df06905e28a7a540f140

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rclone/rclone/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a3aa14e37047081f9770d7c58a0f13e665ed99600259884246b1884fc4b30b6c

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Elon Huang <elonhhuang@gmail.com> \
		Tianling Shen <cnsztl@immortalwrt.org>
PKG_CPE_ID:=cpe:/a:rclone:rclone

PKG_CONFIG_DEPENDS:= \
	CONFIG_RCLONE_COMPRESS_GOPROXY \
	CONFIG_RCLONE_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/rclone/rclone
GO_PKG_EXCLUDES:=test
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	github.com/rclone/rclone/fs.Version=v$(PKG_VERSION) \
	main.Version=v$(PKG_VERSION) \
	main.BuildUser=openwrt \
	main.BuildHost=openwrt

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/rclone/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  TITLE:=rsync for cloud storage
  URL:=https://rclone.org
endef

define Package/rclone
  $(call Package/rclone/Default)
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +fuse3-utils
  USERID:=rclone:rclone
endef

define Package/rclone-config
  $(call Package/rclone/Default)
  TITLE+= (Config Scripts)
  DEPENDS:=+rclone
endef

define Package/rclone/description
  Rclone ("rsync for cloud storage") is a command line program to sync
  files and directories to and from different cloud storage providers.
endef

define Package/rclone/config
config RCLONE_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config RCLONE_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_RCLONE_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/rclone-config/conffiles
/etc/config/rclone
endef

# # Disable CGO due to ld linker issue
# GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_RCLONE_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/rclone
endif
endef

define Package/rclone/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rclone $(1)/usr/bin/
endef

define Package/rclone-config/install
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/rclone.config $(1)/etc/config/rclone
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/rclone.init $(1)/etc/init.d/rclone
endef

$(eval $(call GoBinPackage,rclone))
$(eval $(call BuildPackage,rclone))
$(eval $(call BuildPackage,rclone-config))

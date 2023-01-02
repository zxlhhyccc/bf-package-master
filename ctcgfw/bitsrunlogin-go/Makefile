# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2022 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=BitSrunLoginGo
PKG_VERSION:=3.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Mmx233/BitSrunLoginGo/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f37ea22b72ef2f0fa2b91b57ddd19962e9f849ab9a93bfb3d5e4254026ee497a

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_BITSRUNLOGIN_GO_COMPRESS_GOPROXY \
	CONFIG_BITSRUNLOGIN_GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/Mmx233/BitSrunLoginGo
GO_PKG_LDFLAGS:=-s -w

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/bitsrunlogin-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Campus Network
  TITLE:=Bit Srun auto login tool
  URL:=https://github.com/Mmx233/BitSrunLoginGo
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/bitsrunlogin-go/config
config BITSRUNLOGIN_GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config BITSRUNLOGIN_GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default y if mips||mipsel
endef

ifeq ($(CONFIG_BITSRUNLOGIN_GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/bitsrunlogin-go/conffiles
/etc/config/bitsrunlogin-go
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_BITSRUNLOGIN_GO_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/BitSrunLoginGo
endif
endef

define Package/bitsrunlogin-go/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/BitSrunLoginGo $(1)/usr/bin/bitsrunlogin-go

	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(CURDIR)/files/bitsrunlogin-go.config $(1)/etc/config/bitsrunlogin-go
	$(INSTALL_BIN) $(CURDIR)/files/bitsrunlogin-go.init $(1)/etc/init.d/bitsrunlogin-go
endef

$(eval $(call GoBinPackage,bitsrunlogin-go))
$(eval $(call BuildPackage,bitsrunlogin-go))

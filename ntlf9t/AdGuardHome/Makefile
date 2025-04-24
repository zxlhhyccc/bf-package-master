#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=AdGuardHome
PKG_VERSION:=0.107.61
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/AdguardTeam/AdGuardHome/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=da0cc5f3d1bd0e374bfd72dfb1846c7f0b1a172f176d20526da5eb57631b9521
PKG_BUILD_DIR:=$(BUILD_DIR)/AdGuardHome-$(PKG_VERSION)

FRONTEND_DEST:=$(PKG_NAME)-frontend-$(PKG_VERSION).tar.gz
FRONTEND_URL:=https://github.com/AdguardTeam/AdGuardHome/releases/download/v$(PKG_VERSION)/
FRONTEND_HASH:=69ff3444f06d9c872f38af5b1a90bfd2438bb278fc7aa654f2e72d92835aee7b

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE.txt
PKG_CPE_ID:=cpe:/a:adguard:adguardhome
PKG_MAINTAINER:=Dobroslaw Kijowski <dobo90@gmail.com>, George Sapkin <george@sapk.in>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_CONFIG_DEPENDS:= \
	CONFIG_ADGUARDHOME_COMPRESS_GOPROXY \
	CONFIG_ADGUARDHOME_COMPRESS_UPX

GO_PKG:=github.com/AdguardTeam/AdGuardHome
GO_PKG_BUILD_PKG:=github.com/AdguardTeam/AdGuardHome

GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
AGH_VERSION_PKG:=github.com/AdguardTeam/AdGuardHome/internal/version
GO_PKG_LDFLAGS_X:=$(AGH_VERSION_PKG).channel=release \
	$(AGH_VERSION_PKG).version=$(PKG_VERSION) \
	$(AGH_VERSION_PKG).committime=$(SOURCE_DATE_EPOCH) \
	$(AGH_VERSION_PKG).goarm=$(GO_ARM) \
	$(AGH_VERSION_PKG).gomips=$(GO_MIPS)

ifneq ($(findstring $(ARCH),mips mipsel),)
	ADG_CONF_NAME:=small_flash
else
	ADG_CONF_NAME:=big_space
endif

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/AdGuardHome
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Network-wide ads and trackers blocking DNS server
	URL:=https://github.com/AdguardTeam/AdGuardHome
	DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/AdGuardHome/conffiles
/etc/AdGuardHome/AdGuardHome.yaml
endef

define Package/AdGuardHome/description
Free and open source, powerful network-wide ads and trackers blocking DNS server.
endef

define Package/AdGuardHome/config
config ADGUARDHOME_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config ADGUARDHOME_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_ADGUARDHOME_COMPRESS_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.cn
endif

define Download/AdGuardHome-frontend
	URL:=$(FRONTEND_URL)
	URL_FILE:=AdGuardHome_frontend.tar.gz
	FILE:=$(FRONTEND_DEST)
	HASH:=$(FRONTEND_HASH)
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	gzip -dc $(DL_DIR)/$(FRONTEND_DEST) | $(HOST_TAR) -C $(PKG_BUILD_DIR)/ $(TAR_OPTIONS)
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_ADGUARDHOME_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/AdGuardHome
endif
endef

define Package/AdGuardHome/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/etc/AdGuardHome

	$(INSTALL_CONF) ./conf/$(ADG_CONF_NAME).yaml $(1)/etc/AdGuardHome/AdGuardHome.yaml

	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_CONF) ./conf/adguardhome.sysctl $(1)/etc/sysctl.d/50-AdGuardHome.conf
endef

$(eval $(call Download,AdGuardHome-frontend))
$(eval $(call GoBinPackage,AdGuardHome))
$(eval $(call BuildPackage,AdGuardHome))

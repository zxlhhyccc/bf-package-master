include $(TOPDIR)/rules.mk

PKG_NAME:=syncthing-master
PKG_VERSION:=1.18.4
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=syncthing-source-v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/syncthing/syncthing/releases/download/v$(PKG_VERSION)
PKG_HASH:=163185cf120a7c66fa114937d8712866a891cf09c50eb2995fd49788850c7c02

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/syncthing

PKG_MAINTAINER:=Paul Spooren <mail@aparcar.org>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:syncthing:syncthing

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_CONFIG_DEPENDS:= \
	CONFIG_SYNCTHING_COMPRESS_GOPROXY \
	CONFIG_SYNCTHING_COMPRESS_UPX

GO_PKG:=github.com/syncthing/syncthing/
GO_PKG_BUILD_PKG:=github.com/syncthing/syncthing/cmd/syncthing/
GO_PKG_INSTALL_EXTRA:=^gui/

#GO_PKG_LDFLAGS:= -s -w
GO_PKG_LDFLAGS_X:= \
	github.com/syncthing/syncthing/lib/build.Version=v$(PKG_VERSION) \
	github.com/syncthing/syncthing/lib/build.Stamp=$(SOURCE_DATE_EPOCH) \
	github.com/syncthing/syncthing/lib/build.User=openwrt \
	github.com/syncthing/syncthing/lib/build.Host=openwrt \
	github.com/syncthing/syncthing/lib/build.Program=syncthing
GO_PKG_TAGS:=noupgrade

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/syncthing-master
  TITLE:=Continuous file synchronization program
  URL:=https://syncthing.net
  DEPENDS:=$(GO_ARCH_DEPENDS)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=File Transfer
  USERID:=syncthing=499:syncthing=499
endef

define Package/syncthing-master/conffiles
/etc/config/syncthing
/etc/syncthing
endef

define Package/syncthing-master/description
		Syncthing replaces proprietary sync and cloud services with something
		open, trustworthy and decentralized. Your data is your data alone and
		you deserve to choose where it is stored, if it is shared with some
		third party and how it's transmitted over the Internet.
endef

define Package/syncthing-master/config
	config SYNCTHING_COMPRESS_GOPROXY
		bool "Compiling with GOPROXY proxy"
		default n

	config SYNCTHING_COMPRESS_UPX
		bool "Compress executable files with UPX"
		depends on !mips64
		default y if mips||mipsel
endef

ifeq ($(CONFIG_SYNCTHING_COMPRESS_GOPROXY),y)
export GO111MODULE=on
export GOPROXY=https://goproxy.io
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_SYNCTHING_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/syncthing
endif
endef

define Package/syncthing-master/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(CP) ./files/* $(1)/
endef

$(eval $(call GoBinPackage,syncthing-master))
$(eval $(call BuildPackage,syncthing-master))

include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-dev
PKG_VERSION:=1.18.0-13
PKG_RELEASE:=1
PKG_REV=d034a40
# PKG_REV=e7ac74d

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-g$(PKG_REV).tar.gz
PKG_SOURCE_URL:=https://github.com/Dreamacro/clash.git
# PKG_SOURCE_URL:=https://github.com/MerlinKodo/clash-rev.git
# PKG_SOURCE_VERSION:=e7ac74df95665f2f0f1cf4ed54ece204558865cb
PKG_SOURCE_VERSION:=d034a408be42815e98f3aea80be24949946aea83
PKG_MIRROR_HASH:=309d7c5fbbd9071ea6ccff5bb09f0ca24db0c415ed2a1d7b22a0de0eaf9cf3a5

PKG_MAINTAINER:=EkkoG <beijiu572@gmail.om>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

PKG_CONFIG_DEPENDS:= \
	CONFIG_CLASH-DEV_COMPRESS_GOPROXY \
	CONFIG_CLASH-DEV_COMPRESS_UPX

GO_PKG:=github.com/Dreamacro/clash
# GO_PKG:=github.com/MerlinKodo/clash-rev
GO_PKG_BUILD_PKG:=$(GO_PKG)
GO_PKG_LDFLAGS:= -s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/constant.Version=v$(PKG_VERSION)-g$(PKG_REV)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/../feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)/template
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
endef

define Package/$(PKG_NAME)
	$(call Package/$(PKG_NAME)/template)
	TITLE:=A rule-based tunnel in Go
	URL:=https://github.com/Dreamacro/clash
	DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
endef

define Package/$(PKG_NAME)/description
	Clash, A rule based tunnel in Go, support VMess, Shadowsocks,
	Trojan, Snell protocol for remote connections.
endef

define Package/$(PKG_NAME)/config
    config CLASH-DEV_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config CLASH-DEV_COMPRESS_UPX
      bool "Compress executable files with UPX"
      depends on !mips64
      default n
endef

ifneq ($(CONFIG_CLASH-DEV_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_CLASH-DEV_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/clash
endif
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/etc/openclash/core
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clash $(1)/etc/openclash/core/clash
endef


$(eval $(call BuildPackage,$(PKG_NAME)))

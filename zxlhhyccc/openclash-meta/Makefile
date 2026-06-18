include $(TOPDIR)/rules.mk

PKG_NAME:=openclash-meta
PKG_BASE_VERSION:=1.19.27
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
# PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-g$(PKG_REV).tar.gz
PKG_SOURCE_URL:=https://github.com/MetaCubeX/mihomo.git
PKG_SOURCE_VERSION:=8e2aba40fc9120592703da7ba3e327e24c49fcc8
PKG_MIRROR_HASH:=8e6675966c39ec40cb1c572dbfd2a8ab344a2b59153a83ca4e73696f7478e244

# PKG_REV:=$(shell git rev-parse --short=7 $(PKG_SOURCE_VERSION))
PKG_REV:=$(shell echo $(PKG_SOURCE_VERSION) | cut -c1-7)
PKG_VERSION:=$(PKG_BASE_VERSION)~$(call version_abbrev,$(PKG_SOURCE_VERSION))

PKG_MAINTAINER:=EkkoG <beijiu572@gmail.om>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

# PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-g$(PKG_REV)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

PKG_BUILD_VERSION:=alpha-g$(PKG_REV)
PKG_BUILD_TIME:=$(shell date -u -Iseconds)

PKG_CONFIG_DEPENDS:= \
	CONFIG_CLASH-META_COMPRESS_GOPROXY \
	CONFIG_CLASH-META_COMPRESS_UPX

GO_PKG:=github.com/metacubex/mihomo
GO_PKG_TAGS:=with_gvisor
GO_PKG_LDFLAGS:= -s -w -buildid=
GO_PKG_LDFLAGS_X:=\
	$(GO_PKG)/constant.Version=$(PKG_BUILD_VERSION) \
	$(GO_PKG)/constant.BuildTime=$(PKG_BUILD_TIME)
GO_PKG_INSTALL_BIN_PATH:=/usr/bin

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/../feeds/packages/lang/golang/golang-package.mk

# TAR_OPTIONS+= --strip-components 1
# TAR_CMD:=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Package/$(PKG_NAME)
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Web Servers/Proxies
	TITLE:=A rule-based tunnel in Go
	URL:=https://github.com/MetaCubeX/Clash.Meta
	DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
	ALTERNATIVES:=\
	  300:/etc/openclash/core/clash_meta:/usr/bin/clash_meta
endef

define Package/$(PKG_NAME)/description
	Clash, A rule based tunnel in Go, support VMess, Shadowsocks,
	Trojan, Snell protocol for remote connections.
endef

define Package/$(PKG_NAME)/config
    config CLASH-META_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config CLASH-META_COMPRESS_UPX
      bool "Compress executable files with UPX"
      depends on !mips64
      default n
endef

ifneq ($(CONFIG_CLASH-META_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifeq ($(CONFIG_CLASH-META_COMPRESS_UPX),y)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/mihomo
endif
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(1))
	mv $(1)/usr/bin/mihomo $(1)/usr/bin/clash_meta
endef

define Build/Prepare
	$(Build/Prepare/Default)
	$(RM) -r $(PKG_BUILD_DIR)/rules/logic_test
endef

$(eval $(call GoBinPackage,$(PKG_NAME)))
$(eval $(call BuildPackage,$(PKG_NAME)))

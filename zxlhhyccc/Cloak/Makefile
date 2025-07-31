include $(TOPDIR)/rules.mk

PKG_NAME:=Cloak
PKG_VERSION:=2.12.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/cbeuw/Cloak/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ef5036280c9b8fcf3344f5f254bda2ee5c58e0aa07c72b42cb88f6ffd51eb8f0

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Zxl hhyccc <zxlhhy@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_CLOAK_$(1)_COMPRESS_GOPROXY \
	CONFIG_CLOAK_$(1)_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/cbeuw/Cloak
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/...
GO_PKG_LDFLAGS:=-s -w -X 'main.VERSION=$(PKG_VERSION)'

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/Cloak/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))

	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $(1)/usr/bin/
endef

define Package/Cloak/template
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=$(1) - Cloak is a pluggable transport $(2)
    URL:=https://github.com/cbeuw/Cloak
    DEPENDS:=$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
    $(1) Cloak is a pluggable transport for advanced censorship evasion.
  endef

  define Package/$(1)/config
    config CLOAK_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config CLOAK_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_CLOAK_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/$(1)/install
    $(call Package/Cloak/install,$$(1),$(1))
  endef
endef

CLOAK_COMPONENTS:=ck-client ck-server

define Build/Compile
	$(call GoPackage/Build/Compile)
$(foreach component,$(CLOAK_COMPONENTS),
  ifneq ($(CONFIG_CLOAK_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(component)
  endif
)
endef

$(foreach component,$(CLOAK_COMPONENTS), \
  $(eval $(call Package/Cloak/template,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)

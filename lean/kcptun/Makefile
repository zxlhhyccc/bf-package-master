include $(TOPDIR)/rules.mk

PKG_NAME:=kcptun
PKG_VERSION:=20260314
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/xtaci/kcptun/tar.gz/v${PKG_VERSION}?
PKG_SOURCE_URL:=https://github.com/zxlhhyccc/kcptun/releases/download/v${PKG_VERSION}
PKG_HASH:=02db422e5b423f56b4057165c72cca0003d64ad437b4c6576ecbbe73182cc07d

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>, Chao Liu <expiron18@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_CONFIG_DEPENDS:= \
	CONFIG_KCPTUN_$(1)_COMPRESS_GOPROXY \
	CONFIG_KCPTUN_$(1)_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

KCPTUN_COMPONENTS := client server

GO_PKG:=github.com/xtaci/kcptun
GO_PKG_BUILD_PKG:=github.com/xtaci/kcptun/...
GO_PKG_LDFLAGS:=-s -w -X 'main.VERSION=$(PKG_VERSION)'

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/kcptun/Default
  define Package/kcptun-$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=KCP-based Secure Tunnel $(1)
    DEPENDS:=$(GO_ARCH_DEPENDS)
    URL:=https://github.com/xtaci/kcptun
  endef

  define Package/kcptun-$(1)/description
    kcptun is a Stable & Secure Tunnel Based On KCP with N:M Multiplexing.
This package only contains kcptun $(1).
  endef

  define Package/kcptun-$(1)/config
    config KCPTUN_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config KCPTUN_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_KCPTUN_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/kcptun-$(1)/install
		$$(call GoPackage/Package/Install/Bin,$$(PKG_INSTALL_DIR))

		$$(INSTALL_DIR) $$(1)/usr/bin
		$$(INSTALL_BIN) $$(PKG_INSTALL_DIR)/usr/bin/$(1) $$(1)/usr/bin/kcptun-$(1)
  endef
endef

define Build/UpdateDependencies
	cd $(PKG_BUILD_DIR) && \
		go mod tidy && \
		go mod vendor
endef

define Build/Compile
	$(call Build/UpdateDependencies)
	$(eval GO_PKG_BUILD_PKG:=)
	$(foreach component,$(KCPTUN_COMPONENTS), \
	  $(if $(CONFIG_PACKAGE_kcptun-$(component)), \
	    $(eval GO_PKG_BUILD_PKG += github.com/xtaci/kcptun/$(component)) \
	  )
	)
ifneq ($(strip $(GO_PKG_BUILD_PKG)),)
	$(call GoPackage/Build/Compile)
endif
$(foreach component,$(KCPTUN_COMPONENTS),
  $(if $(CONFIG_PACKAGE_kcptun-$(component)), \
  ifneq ($(CONFIG_KCPTUN_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(component)
  endif
  )
)
endef

$(foreach component,$(KCPTUN_COMPONENTS), \
  $(eval $(call Package/kcptun/Default,$(component))) \
  $(eval $(call GoBinPackage,kcptun-$(component))) \
  $(eval $(call BuildPackage,kcptun-$(component))) \
)

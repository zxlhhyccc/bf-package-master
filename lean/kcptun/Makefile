include $(TOPDIR)/rules.mk

PKG_NAME:=kcptun
PKG_VERSION:=20221015
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/xtaci/kcptun/tar.gz/v${PKG_VERSION}?
#PKG_SOURCE_DATE:=2021-09-22
#PKG_HASH:=f6a08f0fe75fa85d15f9c0c28182c69a5ad909229b4c230a8cbe38f91ba2d038
PKG_SOURCE_URL:=https://github.com/xtaci/kcptun.git
PKG_SOURCE_VERSION:=b4684d7d908f6246988b3cda3dc84615ad84c991
PKG_MIRROR_HASH:=ca89d64591a0aa9ce8b065cc79bf378ad79709dc7edec61c6b733df1d1e0749e

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>, Chao Liu <expiron18@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_CONFIG_DEPENDS:= \
	CONFIG_KCPTUN_$(1)_COMPRESS_GOPROXY \
	CONFIG_KCPTUN_$(1)_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/xtaci/kcptun

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

KCPTUN_COMPONENTS:=server client

define Build/Compile
	$(call GoPackage/Build/Compile)
$(foreach component,$(KCPTUN_COMPONENTS),
  ifneq ($(CONFIG_KCPTUN_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(component)
  endif
)
endef

$(foreach component,$(KCPTUN_COMPONENTS), \
  $(eval $(call Package/kcptun/Default,$(component))) \
  $(eval $(call GoBinPackage,kcptun-$(component))) \
  $(eval $(call BuildPackage,kcptun-$(component))) \
)

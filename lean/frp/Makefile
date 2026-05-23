include $(TOPDIR)/rules.mk

PKG_NAME:=frp
PKG_VERSION:=0.69.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fatedier/frp/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b78879e74e44bb22805a8a4602c6f58b9f46971c003eb4079d5020f66e57ed37

PKG_CONFIG_DEPENDS:= \
	CONFIG_FRP_$(1)_COMPRESS_GOPROXY \
	CONFIG_FRP_$(1)_COMPRESS_UPX

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=golang/host node/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

FRP_COMPONENTS:=frpc frps

GO_PKG:=github.com/fatedier/frp
GO_PKG_BUILD_PKG:=github.com/fatedier/frp/cmd/...
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=github.com/fatedier/frp/pkg/util/version.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Build/Compile
	( \
	    $(foreach component,$(FRP_COMPONENTS),\
	        $(if $(CONFIG_PACKAGE_$(component)), \
		    $(MAKE) -C $(PKG_BUILD_DIR)/web/$(component) install ; \
	        ) \
	    ) \
	    $(MAKE) -C $(PKG_BUILD_DIR) web ; \
	    $(call GoPackage/Build/Compile) ; \
	)
$(foreach component,$(FRP_COMPONENTS),
  $(if $(CONFIG_PACKAGE_$(component)), \
  ifneq ($(CONFIG_FRP_$(component)_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/$(component)
  endif
  )
)
endef

define Package/frp/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_DIR) $(1)/etc/init.d/

	$(INSTALL_BIN) $(GO_PKG_BUILD_BIN_DIR)/$(2) $(1)/usr/bin/
	$(INSTALL_CONF) ./files/$(2).config $(1)/etc/config/$(2)
	$(INSTALL_BIN)  ./files/$(2).init   $(1)/etc/init.d/$(2)

	if [ -r ./files/$(2).uci-defaults ]; then \
		$(INSTALL_DIR) $(1)/etc/uci-defaults; \
		$(INSTALL_DATA) ./files/$(2).uci-defaults $(1)/etc/uci-defaults/$(2); \
	fi
endef

define Package/frp/template
  define Package/$(1)
    SECTION:=net
    CATEGORY:=Network
    SUBMENU:=Web Servers/Proxies
    TITLE:=$(1) - fast reverse proxy $(2)
    URL:=https://github.com/fatedier/frp
    DEPENDS:=$(GO_ARCH_DEPENDS)
  endef

  define Package/$(1)/description
    $(1) is a fast reverse proxy $(2) that helps you expose a local server
    behind a NAT or firewall to the internet.
  endef

  define Package/$(1)/config
    config FRP_$(1)_COMPRESS_GOPROXY
      bool "Compiling with GOPROXY proxy"
      default n

    config FRP_$(1)_COMPRESS_UPX
      bool "Compress $(1) with UPX"
      depends on !mips64
      default n
  endef

  ifneq ($(CONFIG_FRP_$(1)_COMPRESS_GOPROXY),)
      export GO111MODULE=on
      export GOPROXY=https://goproxy.baidu.com
  endif

  define Package/$(1)/conffiles
/etc/config/$(1)
  endef

  define Package/$(1)/install
    $(call Package/frp/install,$$(1),$(1))
  endef
endef

$(foreach component,$(FRP_COMPONENTS), \
  $(eval $(call Package/frp/template,$(component))) \
  $(eval $(call GoBinPackage,$(component))) \
  $(eval $(call BuildPackage,$(component))) \
)


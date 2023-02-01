#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SagerNet/sing-box/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0f3d58ad946ef0283ad651630bbae35d86234f41fc783613007d5ccc33ceb38d

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=LICENSE

PKG_CONFIG_DEPENDS:= \
	CONFIG_SING_BOX_COMPRESS_GOPROXY \
	CONFIG_SING_BOX_COMPRESS_UPX \
	CONFIG_TAG_$(PKG_NAME)_ACME \
	CONFIG_TAG_$(PKG_NAME)_CLASH_API \
	CONFIG_TAG_$(PKG_NAME)_ECH \
	CONFIG_TAG_$(PKG_NAME)_GVISOR \
	CONFIG_TAG_$(PKG_NAME)_GRPC \
	CONFIG_TAG_$(PKG_NAME)_QUIC \
	CONFIG_TAG_$(PKG_NAME)_SHADOWSOCKSR \
	CONFIG_TAG_$(PKG_NAME)_UTLS \
	CONFIG_TAG_$(PKG_NAME)_WIREGUARD

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/sagernet/sing-box
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/sing-box
GO_PKG_LDFLAGS:=-s -w 
GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The universal proxy platform.
  URL:=https://sing-box.sagernet.org
    DEPENDS:=$(GO_ARCH_DEPENDS) \
    +ca-bundle \
    +kmod-inet-diag \
    +kmod-netlink-diag \
    +SING_BOX_BUILD_GVISOR:kmod-tun
endef

GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0

define Package/$(PKG_NAME)/config
    config SING_BOX_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

    config SING_BOX_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n

  menu "Customizing build tags"

    config TAG_$(PKG_NAME)_ACME
      bool "Build with ACME TLS certificate issuer support"
      default n

    config TAG_$(PKG_NAME)_CLASH_API
      bool "Build with Clash API support (EXPERIMENTAL!!!)"
      default y

    config TAG_$(PKG_NAME)_ECH
      bool "Build with TLS ECH extension support"
      default n

    config TAG_$(PKG_NAME)_GVISOR
      bool "Build with gVisor support"
      default n

    config TAG_$(PKG_NAME)_GRPC
      bool "Build with standard gRPC support"
      default n
    help
      Standard gRPC has good compatibility but poor performance.

    config TAG_$(PKG_NAME)_QUIC
      bool "Build with QUIC support"
      default y
      help
        Required by HTTP3 DNS transports, Naive inbound,
        Hysteria inbound / outbound, and v2ray QUIC transport.

    config TAG_$(PKG_NAME)_SHADOWSOCKSR
      bool "Build with ShadowsockR support"
      default n

    config TAG_$(PKG_NAME)_UTLS
      bool "Build with uTLS support"
      default y

    config TAG_$(PKG_NAME)_WIREGUARD
      bool "Build with WireGuard support"
      default y

  endmenu
endef

PKG_BUILD_TAGS:=
ifneq ($(CONFIG_TAG_$(PKG_NAME)_ACME),)
  PKG_BUILD_TAGS+=with_acme
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_CLASH_API),)
  PKG_BUILD_TAGS+=with_clash_api
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_ECH),)
  PKG_BUILD_TAGS+=with_ech
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_GVISOR),)
  PKG_BUILD_TAGS+=with_gvisor
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_GRPC),)
  PKG_BUILD_TAGS+=with_grpc
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_QUIC),)
  PKG_BUILD_TAGS+=with_quic
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_SHADOWSOCKSR),)
  PKG_BUILD_TAGS+=with_shadowsocksr
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_UTLS),)
  PKG_BUILD_TAGS+=with_utls
endif
ifneq ($(CONFIG_TAG_$(PKG_NAME)_WIREGUARD),)
  PKG_BUILD_TAGS+=with_wireguard
endif
GO_PKG_TAGS:=$(subst $(space),$(comma),$(strip $(PKG_BUILD_TAGS)))

ifeq ($(CONFIG_SING_BOX_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/$(PKG_NAME)/conffiles
/etc/sing-box/config.json
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_SING_BOX_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/sing-box
endif
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box

	$(INSTALL_DIR) $(1)/etc/sing-box
	$(INSTALL_DATA) ./files/config.json.example $(1)/etc/sing-box/config.json
endef

define Package/$(PKG_NAME)/postinst
#!/bin/sh

# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
	/etc/init.d/sing-box stop >/dev/null 2>&1
	/etc/init.d/sing-box disable >/dev/null 2>&1
fi
exit 0
endef

$(eval $(call GoBinPackage,sing-box))
$(eval $(call BuildPackage,sing-box))

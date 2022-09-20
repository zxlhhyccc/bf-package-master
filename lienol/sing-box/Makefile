#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.1-beta6
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SagerNet/sing-box/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=6cadde3259f79401327bb9fafa4aa6d50a73d1d9680dbc126beea932e2c3be73

PKG_CONFIG_DEPENDS:= \
	CONFIG_SING_BOX_COMPRESS_GOPROXY \
	CONFIG_SING_BOX_COMPRESS_UPX \
	CONFIG_SING_BOX_BUILD_ACME \
	CONFIG_SING_BOX_BUILD_ECH \
	CONFIG_SING_BOX_BUILD_GVISOR \
	CONFIG_SING_BOX_BUILD_QUIC \
	CONFIG_SING_BOX_BUILD_SHADOWSOCKSR \
	CONFIG_SING_BOX_BUILD_UTLS \
	CONFIG_SING_BOX_BUILD_WIREGUARD

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILE:=LICENSE

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/sagernet/sing-box
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/sing-box
GO_PKG_LDFLAGS:=-s -w 
GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/sing-box
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The universal proxy platform.
  URL:=https://sing-box.sagernet.org
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +SING_BOX_BUILD_GVISOR:kmod-tun
endef

define Package/sing-box/config

menu "sing-box Configuration"
	depends on PACKAGE_sing-box

    config SING_BOX_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

    config SING_BOX_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
  endmenu

if PACKAGE_sing-box
    config SING_BOX_BUILD_ACME
    bool "Build with ACME TLS certificate issuer support"
    default n

    config SING_BOX_BUILD_ECH
    bool "Build with TLS ECH extension support"
    default y

    config SING_BOX_BUILD_GVISOR
    bool "Build with gVisor support"
    default y

    config SING_BOX_BUILD_QUIC
    bool "Build with QUIC support"
    default y
    help
      Required by HTTP3 DNS transports, Naive inbound,
      Hysteria inbound / outbound, and v2ray QUIC transport.

    config SING_BOX_BUILD_SHADOWSOCKSR
    bool "Build with ShadowsockR support"
    default n

    config SING_BOX_BUILD_UTLS
    bool "Build with uTLS support"
    default n

    config SING_BOX_BUILD_WIREGUARD
    bool "Build with WireGuard support"
    default n
  endif
endef

ifneq ($(CONFIG_SING_BOX_BUILD_ACME),)
  GO_PKG_TAGS+=with_acme
endif
ifneq ($(CONFIG_SING_BOX_BUILD_ECH),)
  GO_PKG_TAGS+=with_ech
endif
ifneq ($(CONFIG_SING_BOX_BUILD_GVISOR),)
  GO_PKG_TAGS+=gvisor
endif
ifneq ($(CONFIG_SING_BOX_BUILD_QUIC),)
  GO_PKG_TAGS+=with_quic
endif
ifneq ($(CONFIG_SING_BOX_BUILD_SHADOWSOCKSR),)
  GO_PKG_TAGS+=with_shadowsocksr
endif
ifneq ($(CONFIG_SING_BOX_BUILD_UTLS),)
  GO_PKG_TAGS+=with_utls
endif
ifneq ($(CONFIG_SING_BOX_BUILD_WIREGUARD),)
  GO_PKG_TAGS+=with_wireguard
endif
GO_PKG_TAGS:=$(subst $(space),$(comma),$(strip $(GO_PKG_TAGS)))

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

define Package/sing-box/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box

	$(INSTALL_DIR) $(1)/etc/sing-box
	$(INSTALL_DATA) ./files/config.json.example $(1)/etc/sing-box/config.json
endef

define Package/sing-box/postinst
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

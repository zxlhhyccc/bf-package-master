# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2022-2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.10.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/SagerNet/sing-box/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cae964985e6f27a1ddefc074849a950437e27ef5bfb44847d5ce5d5b2a1b7a27

PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_CONFIG_DEPENDS:= \
	CONFIG_SING_BOX_COMPRESS_GOPROXY \
	CONFIG_SING_BOX_COMPRESS_UPX \
	CONFIG_SING_BOX_BUILD_ACME \
	CONFIG_SING_BOX_BUILD_CLASH_API \
	CONFIG_SING_BOX_BUILD_DHCP \
	CONFIG_SING_BOX_BUILD_ECH \
	CONFIG_SING_BOX_BUILD_EMBEDDED_TOR \
	CONFIG_SING_BOX_BUILD_GRPC \
	CONFIG_SING_BOX_BUILD_GVISOR \
	CONFIG_SING_BOX_BUILD_QUIC \
	CONFIG_SING_BOX_BUILD_REALITY_SERVER \
	CONFIG_SING_BOX_BUILD_UTLS \
	CONFIG_SING_BOX_BUILD_V2RAY_API \
	CONFIG_SING_BOX_BUILD_WIREGUARD

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/sagernet/sing-box
GO_PKG_BUILD_PKG:=$(GO_PKG)/cmd/sing-box
GO_PKG_LDFLAGS:=-s -w 
GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/sing-box
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=The universal proxy platform
  URL:=https://sing-box.sagernet.org/
  DEPENDS:=$(GO_ARCH_DEPENDS) \
    +ca-bundle \
    +kmod-inet-diag \
    +kmod-netlink-diag \
    +kmod-tun
  USERID:=sing-box=5566:sing-box=5566
endef

define Package/sing-box/description
  Sing-box is a universal proxy platform which supports hysteria, SOCKS, Shadowsocks,
  ShadowTLS, Tor, trojan, VLess, VMess, WireGuard and so on.
endef

define Package/sing-box/config
    config SING_BOX_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

    config SING_BOX_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n

  menu "Customizing build tags"
  if PACKAGE_sing-box
    config SING_BOX_BUILD_ACME
	bool "Build with ACME TLS certificate issuer support"

    config SING_BOX_BUILD_CLASH_API
	bool "Build with Clash API support"
	default y

    config SING_BOX_BUILD_DHCP
	bool "Build with DHCP support"
	default y

    config SING_BOX_BUILD_ECH
	bool "Build with TLS ECH extension support"
	default y

    config SING_BOX_BUILD_EMBEDDED_TOR
	bool "Build with embedded Tor support"
	depends on BROKEN

    config SING_BOX_BUILD_GRPC
	bool "Build with standard gPRC support"
	help
      	  Standard gRPC has good compatibility but poor performance.

    config SING_BOX_BUILD_GVISOR
	bool "Build with gVisor support"
	default y

    config SING_BOX_BUILD_QUIC
    	bool "Build with QUIC support"
    	default y
    	help
      	  Required by HTTP3 DNS transports, Naive inbound,
      	  Hysteria inbound / outbound, and v2ray QUIC transport.

    config SING_BOX_BUILD_REALITY_SERVER
      	bool "Build with reality TLS server support"
      	default y

    config SING_BOX_BUILD_UTLS
    	bool "Build with uTLS support"
    	default y

    config SING_BOX_BUILD_V2RAY_API
    	bool "Build with V2Ray API support"

    config SING_BOX_BUILD_WIREGUARD
    	bool "Build with WireGuard support"
    	default y
  endif

  endmenu
endef

GO_PKG_TAGS:=$(subst $(space),$(comma),$(strip \
	$(if $(CONFIG_SING_BOX_BUILD_ACME),with_acme) \
	$(if $(CONFIG_SING_BOX_BUILD_CLASH_API),with_clash_api) \
	$(if $(CONFIG_SING_BOX_BUILD_DHCP),with_dhcp) \
	$(if $(CONFIG_SING_BOX_BUILD_ECH),with_ech) \
	$(if $(CONFIG_SING_BOX_BUILD_EMBEDDED_TOR),with_embedded_tor) \
	$(if $(CONFIG_SING_BOX_BUILD_GRPC),with_grpc) \
	$(if $(CONFIG_SING_BOX_BUILD_GVISOR),with_gvisor) \
	$(if $(CONFIG_SING_BOX_BUILD_QUIC),with_quic) \
	$(if $(CONFIG_SING_BOX_BUILD_REALITY_SERVER),with_reality_server) \
	$(if $(CONFIG_SING_BOX_BUILD_UTLS),with_utls) \
	$(if $(CONFIG_SING_BOX_BUILD_V2RAY_API),with_v2ray_api) \
	$(if $(CONFIG_SING_BOX_BUILD_WIREGUARD),with_wireguard) \
))

define Package/sing-box/conffiles
/etc/sing-box/config.json
/etc/config/sing-box
/etc/sing-box/
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_SING_BOX_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/sing-box
endif
endef

define Package/sing-box/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/sing-box
	#$(INSTALL_DATA) $(PKG_BUILD_DIR)/release/config/config.json $(1)/etc/sing-box
	$(INSTALL_DATA) ./files/config.json.example $(1)/etc/sing-box/config.json.example

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/sing-box.conf $(1)/etc/config/sing-box
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/sing-box.init $(1)/etc/init.d/sing-box
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

include $(TOPDIR)/rules.mk

PKG_NAME:=xray-core
PKG_VERSION:=26.10.17
PKG_RELEASE:=8

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/XTLS/Xray-core.git
PKG_SOURCE_DATE:=2026-10-17
PKG_SOURCE_VERSION:=92ccc939aaf4f8965f369cf0b142e005aeaa11d5
PKG_MIRROR_HASH:=8a43b768cd138692159040fc8422b9f70cb1ff3d67d9d1c01f2ddc735dbd40c9

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=MPL-2.0 GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE proxy/anytls/LICENSE.sing-anytls proxy/naive/LICENSE.sing-box proxy/shadowsocksr/LICENSE proxy/tuic/LICENSE.mihomo proxy/snell/LICENSE.mihomo transport/internet/shadowtls/LICENSE.mihomo

PKG_CONFIG_DEPENDS:= \
	CONFIG_XRAY_CORE_PROVIDE_V2RAY_CORE \
	CONFIG_XRAY_CORE_COMPRESS_GOPROXY \
	CONFIG_XRAY_CORE_COMPRESS_UPX \
	CONFIG_XRAY_CORE_NAIVE

PKG_BUILD_DIR:=$(BUILD_DIR)/xray-core-$(PKG_VERSION)
PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/xtls/xray-core
GO_PKG_BUILD_PKG:=github.com/xtls/xray-core/main
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:= \
	$(GO_PKG)/core.build=OpenWrt \
	$(GO_PKG)/core.version=v$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

# Cronet's native archives contain LLVM bitcode. Use its matching linker while
# retaining OpenWrt's target GCC, sysroot, ABI flags and C runtime.
CRONET_CLANG_VERSION:=llvmorg-24-init-3796-g20e97c4b-27
CRONET_CLANG_FILE:=clang-$(CRONET_CLANG_VERSION).tar.xz
CRONET_CLANG_DIR:=$(PKG_BUILD_DIR)/.cronet-clang

ifeq ($(CONFIG_XRAY_CORE_NAIVE),y)
  GO_PKG_TAGS+=with_naive_outbound
  ifeq ($(CONFIG_USE_MUSL),y)
    GO_PKG_TAGS+=with_musl
  endif
  GO_PKG_BUILD_VARS+=CGO_LDFLAGS="$(TARGET_LDFLAGS) -B$(CRONET_CLANG_DIR)/bin -fuse-ld=lld $(if $(filter arm i386 mipsel loongarch64,$(ARCH)),-Wl$(comma)-no-pie) $(if $(filter loongarch64,$(ARCH)),-Wl$(comma)--no-relax)"

  define Download/cronet-clang
    URL:=https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64
    URL_FILE:=$(CRONET_CLANG_FILE)
    FILE:=$(CRONET_CLANG_FILE)
    HASH:=968195fa0b49958e066695df2c7c985d169a20fa06eedb8fcef900a6030edcb0
  endef
  $(eval $(call Download,cronet-clang))

  define Build/Prepare
    $(call Build/Prepare/Default)
    $(INSTALL_DIR) $(CRONET_CLANG_DIR)
    $(TAR) -xJf $(DL_DIR)/$(CRONET_CLANG_FILE) -C $(CRONET_CLANG_DIR)
  endef
endif

define Package/xray/template
  TITLE:=A proxy platform to bypass network restrictions
  SECTION:=net
  CATEGORY:=Network
  URL:=https://xtls.github.io
endef

define Package/xray-core
  $(call Package/xray/template)
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle
#  PROVIDES:=v2ray-core
  CONFLICTS:=v2ray-core
endef

define Package/xray-example
  $(call Package/xray/template)
  TITLE+= (example configs)
  DEPENDS:=xray-core
  PKGARCH:=all
endef

define Package/xray/description
  Xray, Penetrates Everything. It helps you to build your own computer network.
  It secures your network connections and thus protects your privacy.
endef

define Package/xray-core/description
  $(call Package/xray/description)
endef

define Package/xray-example/description
  $(call Package/xray/description)

  This includes example configuration files for xray-core.
endef

define Package/xray-core/config
menu "Xray-core Configuration"
	depends on PACKAGE_xray-core

config XRAY_CORE_PROVIDE_V2RAY_CORE
	bool "Provide V2Ray binary using XRay"
	default n

config XRAY_CORE_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config XRAY_CORE_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endmenu

config XRAY_CORE_NAIVE
	bool "Enable NaiveProxy outbound (Chromium/Cronet)"
	depends on PACKAGE_xray-core
	depends on (aarch64 || arm || i386 || x86_64 || mipsel || riscv64 || loongarch64)
	depends on (USE_MUSL || USE_GLIBC)
	depends on !arm || (arm_v7 && HAS_FPU)
	default y
	help
	  Link Chromium/Cronet for NaiveProxy HTTP/2 and HTTP/3 outbounds.
	  Requires an x86_64 Linux build host and adds a native library to Xray.
	  Naive inbound support remains available when this option is disabled.
endef

define Package/xray-core/conffiles
/etc/xray/
/etc/config/xray
endef

ifneq ($(CONFIG_XRAY_CORE_COMPRESS_GOPROXY),)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.io
endif

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_XRAY_CORE_COMPRESS_UPX),)
	if ! $(STAGING_DIR_HOST)/bin/upx -t $(GO_PKG_BUILD_BIN_DIR)/main; then \
		$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/main ; \
	fi
endif
endef

define Package/xray-core/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/main $(1)/usr/bin/xray
ifneq ($(CONFIG_XRAY_CORE_PROVIDE_V2RAY_CORE),)
	$(LN) xray $(1)/usr/bin/v2ray
endif

	$(INSTALL_DIR) $(1)/etc/xray/
	$(INSTALL_DATA) $(CURDIR)/files/config.json.example $(1)/etc/xray/

	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) $(CURDIR)/files/xray.conf $(1)/etc/config/xray
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/xray.init $(1)/etc/init.d/xray

	$(INSTALL_DIR) $(1)/etc/capabilities/
	$(INSTALL_DATA) $(CURDIR)/files/xray.capabilities $(1)/etc/capabilities/xray.json
endef

define Package/xray-example/install
	$(INSTALL_DIR) $(1)/etc/xray/
	$(INSTALL_DATA) $(CURDIR)/files/vpoint_socks_vmess.json $(1)/etc/xray/
	$(INSTALL_DATA) $(CURDIR)/files/vpoint_vmess_freedom.json $(1)/etc/xray/
endef

$(eval $(call BuildPackage,xray-core))
$(eval $(call BuildPackage,xray-example))

#
# Copyright (c) 2018-2023 Nick Peng (pymumu@gmail.com)
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=smartdns
PKG_VERSION:=1.2025.47
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pymumu/smartdns.git
PKG_SOURCE_VERSION:=2e60a0cce74da57d4e17eb34bb837e75f4fde45c
PKG_MIRROR_HASH:=423619db2358ca12b13502a967f3458d4b86954ac862a82a6f480b1e04e9d50e

PKG_MAINTAINER:=Nick Peng <pymumu@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

# node compile is slow, so do not use it, download node manually.
# PACKAGE_smartdns-ui:node/host
PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_smartdns-ui
PKG_BUILD_DEPENDS:= \
	PACKAGE_smartdns-ui:rust-bindgen/host \
	PACKAGE_smartdns-ui:rustup/host \
	PACKAGE_smartdns-ui:node/host
PKG_BUILD_PARALLEL:=1

RUST_PKG_FEATURES:=build-release
RUST_PKG_LOCKED:=0

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

MAKE_PATH:=src
MAKE_VARS+= VER=$(PKG_VERSION)

define Package/smartdns/Default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:= smartdns
  URL:=https://www.github.com/pymumu/smartdns/
endef

define Package/smartdns
  $(call Package/smartdns/Default)
  TITLE+= smartdns server
  DEPENDS:=+i386:libatomic +libopenssl
endef

define Package/smartdns/description
SmartDNS is a local DNS server which accepts DNS query requests from local network clients,
gets DNS query results from multiple upstream DNS servers concurrently, and returns the fastest IP to clients.
Unlike dnsmasq's all-servers, smartdns returns the fastest IP, and encrypt DNS queries with DoT or DoH.
endef

define Package/smartdns-ui
  $(call Package/smartdns/Default)
  TITLE+= smartdns dashboard
  DEPENDS:=+smartdns $(RUST_ARCH_DEPENDS) @!(TARGET_x86_geode||TARGET_x86_legacy)
endef

define Package/smartdns-ui/description
A dashboard ui for smartdns server.
endef

define Package/smartdns/conffiles
/etc/config/smartdns
/etc/smartdns/address.conf
/etc/smartdns/blacklist-ip.conf
/etc/smartdns/whitelist-ip.conf
/etc/smartdns/custom.conf
/etc/smartdns/domain-block.list
/etc/smartdns/domain-forwarding.list
endef

define Package/smartdns-ui/conffiles
/etc/config/smartdns
endef

define Download/smartdns-webui
  PROTO:=git
  URL:=https://github.com/pymumu/smartdns-webui.git
  SOURCE_DATE:=2025-12-24
  SOURCE_VERSION:=3261c18b1b93d841e86d9e727557109ae71d71cd
  MIRROR_HASH:=84fb0061ee4f701a51806e0b4d74dc19a6a2e6116a2a9862ae78e7a5d1a6b465
  SUBDIR:=smartdns-webui-$$$$(subst -,.,$$$$(SOURCE_DATE))~$$$$(call version_abbrev,$$$$(SOURCE_VERSION))
  FILE:=$$(SUBDIR).tar.zst
endef

define Build/Prepare
	$(call Build/Prepare/Default)

ifneq ($(CONFIG_PACKAGE_smartdns-ui),)
	$(eval $(call Download,smartdns-webui))
	$(eval $(Download/smartdns-webui))
	mkdir -p $(PKG_BUILD_DIR)/smartdns-webui
	zstdcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR)/smartdns-webui $(TAR_OPTIONS) --strip-components=1
	$(call PatchDir,$(PKG_BUILD_DIR)/smartdns-webui,$(CURDIR)/webui-patches)
endif
endef

define Build/Compile
	$(call Build/Compile/Default)

ifneq ($(CONFIG_PACKAGE_smartdns-ui),)
	( \
		pushd $(PKG_BUILD_DIR) ; \
		pushd plugin/smartdns-ui ; \
		$(CARGO_PKG_CONFIG_VARS) \
		MAKEFLAGS="$(PKG_JOBS)" \
		TARGET_CFLAGS="$(filter-out -O%,$(TARGET_CFLAGS)) $(RUSTC_CFLAGS)" \
		BINDGEN_EXTRA_CLANG_ARGS="--sysroot=$(TOOLCHAIN_ROOT_DIR)" \
		cargo build -v --profile $(CARGO_PKG_PROFILE) \
		$(if $(strip $(RUST_PKG_FEATURES)),--features "$(strip $(RUST_PKG_FEATURES))") \
		$(if $(filter --jobserver%,$(PKG_JOBS)),,-j1) \
		$(CARGO_PKG_ARGS) ; \
		popd ; \
		pushd smartdns-webui ; \
		$(SED) 's/"\^/"/g' package.json ; \
		npm install ; \
		npm run build ; \
		popd ; \
		popd ; \
	)
endif
endef

define Package/smartdns/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d $(1)/usr/share/smartdns
	$(INSTALL_DIR) $(1)/etc/smartdns $(1)/etc/smartdns/domain-set $(1)/etc/smartdns/conf.d/
	$(INSTALL_DIR) $(1)/etc/smartdns/ip-set $(1)/etc/smartdns/download
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/smartdns $(1)/usr/sbin/smartdns
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/package/openwrt/files/etc/init.d/smartdns $(1)/etc/init.d/smartdns
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/address.conf $(1)/etc/smartdns/address.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/blacklist-ip.conf $(1)/etc/smartdns/blacklist-ip.conf
	$(INSTALL_CONF) $(CURDIR)/conf/cfipv4.txt $(1)/etc/smartdns/cfipv4.txt
	$(INSTALL_CONF) $(CURDIR)/conf/custom.conf $(1)/etc/smartdns/custom.conf
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-block.list $(1)/etc/smartdns/domain-block.list
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/package/openwrt/domain-forwarding.list $(1)/etc/smartdns/domain-forwarding.list
	$(INSTALL_CONF) $(CURDIR)/conf/smartdns.conf $(1)/etc/config/smartdns
	$(INSTALL_CONF) $(CURDIR)/conf/whitelist-ip.conf $(1)/etc/smartdns/whitelist-ip.conf
	$(INSTALL_CONF) $(CURDIR)/conf/proxy-domain-list.conf $(1)/etc/smartdns/domain-set/proxy-domain-list.conf
	$(INSTALL_CONF) $(CURDIR)/conf/direct-domain-list.conf $(1)/etc/smartdns/domain-set/direct-domain-list.conf
	$(INSTALL_CONF) $(CURDIR)/conf/hosts.conf $(1)/etc/smartdns/domain-set/hosts.conf
	$(INSTALL_CONF) $(CURDIR)/conf/anti-ad.conf $(1)/etc/smartdns/conf.d/anti-ad.conf
	$(INSTALL_CONF) $(CURDIR)/conf/ipv4list.list $(1)/etc/smartdns/ip-set/ipv4list.list
	$(INSTALL_BIN) $(CURDIR)/conf/update-list.sh $(1)/usr/share/smartdns/update-list.sh
endef

define Package/smartdns-ui/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/smartdns/conf.d/
	$(INSTALL_DIR) $(1)/usr/share/smartdns/wwwroot
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/plugin/smartdns-ui/target/$(RUSTC_TARGET_ARCH)/$(CARGO_PKG_PROFILE)/libsmartdns_ui.so $(1)/usr/lib/smartdns_ui.so
	$(CP) $(PKG_BUILD_DIR)/smartdns-webui/out/* $(1)/usr/share/smartdns/wwwroot
endef

$(eval $(call BuildPackage,smartdns))
$(eval $(call BuildPackage,smartdns-ui))


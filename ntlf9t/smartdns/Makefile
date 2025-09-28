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
PKG_SOURCE_VERSION:=38b5a30abca16de04d4e4bb2bd2358cae758fa6e
PKG_MIRROR_HASH:=1a55ca31befa28e68af6e5d12fe710ca1e89fc463ce11e48d35768634d93330a

PKG_MAINTAINER:=Nick Peng <pymumu@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

# node compile is slow, so do not use it, download node manually.
# PACKAGE_smartdns-ui:node/host
PKG_BUILD_DEPENDS:= \
	PACKAGE_smartdns-ui:rust/host \
	PACKAGE_smartdns-ui:rustup/host \
	PACKAGE_smartdns-ui:node-pnpm/host

include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk
include $(INCLUDE_DIR)/package.mk

MAKE_VARS += VER=$(PKG_VERSION)
MAKE_PATH:=src

define Package/smartdns/default
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  URL:=https://www.github.com/pymumu/smartdns/
endef

define Package/smartdns
  $(Package/smartdns/default)
  TITLE:=smartdns server
  DEPENDS:=+libpthread +libopenssl +libatomic
endef

define Package/smartdns/description
SmartDNS is a local DNS server which accepts DNS query requests from local network clients,
gets DNS query results from multiple upstream DNS servers concurrently, and returns the fastest IP to clients.
Unlike dnsmasq's all-servers, smartdns returns the fastest IP, and encrypt DNS queries with DoT or DoH. 
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

define Package/smartdns-ui
  $(Package/smartdns/default)
  TITLE:=smartdns dashboard
  DEPENDS:=+smartdns $(RUST_ARCH_DEPENDS)
endef

define Package/smartdns-ui/description
A dashboard ui for smartdns server.
endef

define Package/smartdns-ui/conffiles
/etc/config/smartdns
endef

define Package/smartdns-ui/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/smartdns/conf.d/
	$(INSTALL_DIR) $(1)/usr/share/smartdns/wwwroot
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/plugin/smartdns-ui/target/smartdns_ui.so $(1)/usr/lib/smartdns_ui.so
	$(CP) $(PKG_BUILD_DIR)/smartdns-webui/out/* $(1)/usr/share/smartdns/wwwroot
endef

define Build/Compile/smartdns-ui
	cargo install --force --locked bindgen-cli
	CARGO_BUILD_ARGS="$(if $(strip $(RUST_PKG_FEATURES)),--features "$(strip $(RUST_PKG_FEATURES))") --profile $(CARGO_PKG_PROFILE)"
	+$(CARGO_PKG_VARS) CARGO_BUILD_ARGS="$(CARGO_BUILD_ARGS)" CC=$(TARGET_CC) CFLAGS="-O0" \
	PATH="$$(PATH):$(CARGO_HOME)/bin" \
	make -C $(PKG_BUILD_DIR)/plugin/smartdns-ui
endef

define Build/Compile/smartdns-webui
	which pnpm || (echo "pnpm not found, please install pnpm first" && exit 1)
	pnpm install --prefix $(PKG_BUILD_DIR)/smartdns-webui/
	cd $(PKG_BUILD_DIR)/smartdns-webui && pnpm run build
endef

SMARTDNS_WEBUI_VERSION:=1.0.0
SMARTDNS_WEBUI_FILE:=smartdns-webui-$(SMARTDNS_WEBUI_VERSION).tar.gz
define Download/smartdns-webui
	URL:=https://codeload.github.com/zxlhhyccc/smartdns-webui/tar.gz/v$(SMARTDNS_WEBUI_VERSION)?
	FILE:=$(SMARTDNS_WEBUI_FILE)
	HASH:=1861f36b2821190dd0085dbea2166853013cccef12756baa26d7c83e5f460aab
	SUBDIR:=smartdns-webui
endef

$(eval $(call Download,smartdns-webui))

ifeq ($(CONFIG_PACKAGE_smartdns-ui),y)
define Build/Prepare
	$(call Build/Prepare/Default)
	$(TAR) -C $(PKG_BUILD_DIR)/ -xf $(DL_DIR)/$(SMARTDNS_WEBUI_FILE)
	mv $(PKG_BUILD_DIR)/smartdns-webui-$(SMARTDNS_WEBUI_VERSION) $(PKG_BUILD_DIR)/smartdns-webui
endef
endif

define Build/Compile
	$(call Build/Compile/Default,smartdns)
ifeq ($(CONFIG_PACKAGE_smartdns-ui),y)
	$(call Build/Compile/smartdns-ui)
	$(call Build/Compile/smartdns-webui)
endif
endef

$(eval $(call BuildPackage,smartdns))
$(eval $(call RustBinPackage,smartdns-ui))
$(eval $(call BuildPackage,smartdns-ui))


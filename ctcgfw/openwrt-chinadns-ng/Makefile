# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2023 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=chinadns-ng
PKG_VERSION:=2024.04.13
PKG_RELEASE:=1

ifeq ($(ARCH),aarch64)
  PKG_ARCH:=chinadns-ng@aarch64-linux-musl@generic+v8a@fast+lto
  PKG_HASH:=dddbfcde000d4178fee2f8cdcfec7f10f8deb1f6673f9046b35d340dd2182ac5
else ifeq ($(ARCH),arm)
  ARM_CPU_FEATURES:=$(word 2,$(subst +,$(space),$(call qstrip,$(CONFIG_CPU_TYPE))))
  ifeq ($(ARM_CPU_FEATURES),)
    PKG_ARCH:=chinadns-ng@arm-linux-musleabi@generic+v6+soft_float@fast+lto
    PKG_HASH:=08fb1ae28eeb41ff48e9fd3b0dea3f58111885f1a39acea91978a883fb3d62ed
  else
    PKG_ARCH:=chinadns-ng@arm-linux-musleabihf@generic+v7a@fast+lto
    PKG_HASH:=2653bc82f8ae622e793c28933da55321aef82e8b923df9fd3cedb72f3f34fa90
  endif
else ifeq ($(ARCH),mips)
  PKG_ARCH:=chinadns-ng@mips-linux-musl@mips32+soft_float@fast+lto
  PKG_HASH:=0245d23021867461524398b1074fc13abf8aae56ae93faa1ecd78b1bda6b5d76
else ifeq ($(ARCH),mipsel)
  PKG_ARCH:=chinadns-ng@mipsel-linux-musl@mips32+soft_float@fast+lto
  PKG_HASH:=15845a0b03deba4e407dda963d60f47623e93fdf5d0e9ab0f83baa25be0bb36f
else ifeq ($(ARCH),i386)
  PKG_ARCH:=chinadns-ng@i386-linux-musl@i686@fast+lto
  PKG_HASH:=5bfdf006971be9c96f59c797c554972337197aaf5d9b6d8402da61738147653d
else ifeq ($(ARCH),x86_64)
  PKG_ARCH:=chinadns-ng@x86_64-linux-musl@x86_64@fast+lto
  PKG_HASH:=af11c02a80f5b7db69832c86a15126adf822d54e8f0aa38bb1d88f75449180bc
else
  PKG_SOURCE:=dummy
  PKG_HASH:=dummy
endif

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(ARCH_PACKAGES)
PKG_SOURCE_URL:=https://github.com/zfl9/chinadns-ng/releases/download/$(PKG_VERSION)/$(PKG_ARCH)?
UNPACK_CMD=$(CP) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/$(PKG_NAME)

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=sbwml <admin@cooluc.com>

include $(INCLUDE_DIR)/package.mk

define Package/chinadns-ng
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=ChinaDNS next generation, refactoring with epoll and ipset.
  URL:=https://github.com/zfl9/chinadns-ng
  DEPENDS:=@(aarch64||arm||i386||mips||mipsel||x86_64) @!(TARGET_x86_geode||TARGET_x86_legacy)
endef

define Package/chinadns-ng/description
ChinaDNS Next Generation, refactoring with epoll and ipset.
endef

define Package/chinadns-ng/conffiles
/etc/config/chinadns-ng
/etc/chinadns-ng/chnroute.txt
/etc/chinadns-ng/chnroute6.txt
/etc/chinadns-ng/gfwlist.txt
/etc/chinadns-ng/chinalist.txt
endef

define Build/Compile
endef

define Package/chinadns-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chinadns-ng $(1)/usr/bin
	$(INSTALL_BIN) files/chinadns-ng-daily.sh $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/chinadns-ng.init $(1)/etc/init.d/chinadns-ng
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/chinadns-ng.config $(1)/etc/config/chinadns-ng
	$(INSTALL_DIR) $(1)/etc/chinadns-ng
	$(INSTALL_DATA) files/chnroute.txt $(1)/etc/chinadns-ng
	$(INSTALL_DATA) files/chnroute6.txt $(1)/etc/chinadns-ng
	$(INSTALL_DATA) files/gfwlist.txt $(1)/etc/chinadns-ng
	$(INSTALL_DATA) files/chinalist.txt $(1)/etc/chinadns-ng
endef

define Package/chinadns-ng/postinst
#!/bin/sh
if ! crontab -l | grep -q "chinadns-ng"; then
  (crontab -l; echo -e "# chinadns-ng\n10 3 * * * /usr/bin/chinadns-ng-daily.sh") | crontab -
fi
exit 0
endef

define Package/chinadns-ng/postrm
#!/bin/sh
rmdir --ignore-fail-on-non-empty /etc/chinadns-ng
(crontab -l | grep -v "chinadns-ng") | crontab -
exit 0
endef

$(eval $(call BuildPackage,chinadns-ng))

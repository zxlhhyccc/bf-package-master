#
# Copyright (C) 2015-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tuic-client
PKG_VERSION:=1.0.0

#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://codeload.github.com/EAimTY/tuic/tar.gz/tuic-client-$(PKG_VERSION)?
#PKG_HASH:=64d81f3d5c79d9d69229e927c3f842849885f547020d897f9624d185819e5661

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/EAimTY/tuic.git
PKG_SOURCE_VERSION:=0acf4844c46e63b83eab3e58069fe8c060509974
PKG_MIRROR_HASH:=745270886fed31741cbc3e01c6cf1bc6c522dcbb0aa412b8366d4399f578fc4b
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)/$(PKG_NAME)

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/rust/rust-package.mk

TAR_OPTIONS+= --strip-components 1
TAR_CMD=$(HOST_TAR) -C $(1)/.. $(TAR_OPTIONS)

define Package/tuic-client
  	SECTION:=net
  	CATEGORY:=Network
  	SUBMENU:=Web Servers/Proxies
  	TITLE:=Delicately-TUICed 0-RTT proxy protocol (client)
  	URL:=https://github.com/EAimTY/tuic
  	DEPENDS:=@(aarch64||arm||x86_64)
endef

$(eval $(call RustBinPackage,tuic-client))
$(eval $(call BuildPackage,tuic-client))

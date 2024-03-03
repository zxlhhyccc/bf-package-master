include $(TOPDIR)/rules.mk

PKG_NAME:=microsocks
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rofl0r/microsocks/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=130127a87f55870f18fbe47a64d9b9533020e2900802d36a0f6fd2b074313deb

#PKG_SOURCE_PROTO:=git
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_SOURCE_URL:=https://github.com/rofl0r/microsocks.git
#PKG_SOURCE_DATE:=2022-09-18
#PKG_SOURCE_VERSION:=655c53d27df0bd69e0ecfa8309ce2940797f3362
#PKG_MIRROR_HASH:=d047882cf489a8408c8d870f583f9263779dc6a8ec11da1e106fc5684aceb5f7

PKG_MAINTAINER:=Mateusz Korniak <matkorgithubcom@ant.gliwice.pl>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/microsocks
  SECTION:=net
  SUBMENU:=Web Servers/Proxies
  CATEGORY:=Network
  TITLE:=SOCKS5 TCP/IP only proxy
endef

define Package/microsocks/description
  Low resource SOCKS5 proxy.
  Supports only SOCKS5 protocol and forwarding only TCP/IP connections.
endef

define Package/microsocks/conffiles
/etc/config/microsocks
endef

TARGET_CFLAGS+= -flto
TARGET_LDFLAGS+= -flto -Wl,--gc-sections,--as-needed

define Package/microsocks/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/microsocks $(1)/usr/bin

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/microsocks.config $(1)/etc/config/microsocks
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/microsocks.init $(1)/etc/init.d/microsocks
endef

$(eval $(call BuildPackage,microsocks))

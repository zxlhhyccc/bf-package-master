include $(TOPDIR)/rules.mk

PKG_NAME:=mhz
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/wtarreau/mhz.git
PKG_SOURCE_DATE:=2024-02-01
PKG_SOURCE_VERSION:=d84a678acd8a64c045ffeb72cc464389d8da25e9
PKG_MIRROR_HASH:=56203c110a47b7c7fe68347185ad9936d7695821aa029c42296d6f02ea70fea5

PKG_MAINTAINER:=Robert Marko <robimarko@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/mhz
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=CPU frequency measurement utility
endef

define Package/mhz/description
  Tool to mathematically calculate the current CPU frequency.
endef

define Package/mhz/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mhz $(1)/usr/sbin/mhz
endef

$(eval $(call BuildPackage,mhz))

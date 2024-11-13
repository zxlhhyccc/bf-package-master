include $(TOPDIR)/rules.mk

PKG_NAME:=control-vlmcsd
PKG_VERSION=svn1113
PKG_RELEASE:=2

PKG_MAINTAINER:=fuyumi <280604399@qq.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Wind4/vlmcsd.git
PKG_SOURCE_VERSION:=65228e5c7916acd947ffb53be18abadafbc1be56
PKG_MIRROR_HASH:=b25e7a003b64ac5d76878cf0cfc249de3de8efb64bb1e35c70e862d50742537c

PKG_SOURCE_SUBDIR:=$(PKG_NAME)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/control-vlmcsd
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A KMS Emulator in C
  URL:=http://forums.mydigitallife.info/threads/50234
  DEPENDS:=+libpthread
endef

define Package/control-vlmcsd/description
  KMS Emulator in C (currently runs on Linux including Android, FreeBSD,
  Solaris, Minix, Mac OS, iOS, Windows with or without Cygwin)
endef

define Build/Compile
	$(SED) 's/private build/$(PKG_VERSION)/' $(PKG_BUILD_DIR)/src/config.h
	$(call Build/Compile/Default)
endef

define Package/control-vlmcsd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/vlmcsd $(1)/usr/bin/vlmcsd
endef

$(eval $(call BuildPackage,control-vlmcsd))

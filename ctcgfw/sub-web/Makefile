include $(TOPDIR)/rules.mk

PKG_NAME:=sub-web
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/CareyWang/sub-web.git
PKG_SOURCE_DATE:=2023-10-08
PKG_SOURCE_VERSION:=b71f372dc52ab535559840402edf4fcb32bc4bd2
PKG_MIRROR_HASH:=8c54be8a5aa8ad16e0700712ced576d6c069390956685a86fb5f9784f81db263

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=node/host node-yarn/host

include $(INCLUDE_DIR)/package.mk

define Package/sub-web
  SECTION:=net
  CATEGORY:=Network
  URL:=https://github.com/CareyWang/sub-web
  TITLE:=A WebUI for generating proxy subscription url
  DEPENDS:=+subconverter
  PKGARCH:=all
endef

define Package/sub-web/description
  Based on vue-cli and subconverter, for generating proxy subscription
  url automatically.
endef

define Build/Compile
	( \
		pushd "$(PKG_BUILD_DIR)"; \
		yarn install; \
		NODE_OPTIONS=--openssl-legacy-provider yarn build; \
		popd ; \
	)
endef

define Package/sub-web/install
	$(INSTALL_DIR) $(1)/www/sub-web
	$(CP) $(PKG_BUILD_DIR)/dist/* $(1)/www/sub-web/
endef

$(eval $(call BuildPackage,sub-web))

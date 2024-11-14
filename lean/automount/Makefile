#
# Copyright (C) 2010-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=automount
PKG_FLAGS:=nonshared
PKG_RELEASE:=10

PKG_CONFIG_DEPENDS:= \
	CONFIG_LINUX_5_4 \
	CONFIG_TARGET_ramips \
	CONFIG_USB_SUPPORT

include $(INCLUDE_DIR)/package.mk

define Package/automount
  TITLE:=Mount autoconfig hotplug script.
  MAINTAINER:=Lean
  DEPENDS:= \
	+block-mount \
	+e2fsprogs \
	+USB_SUPPORT:kmod-usb-storage \
	+USB_SUPPORT:kmod-usb-storage-extras \
	+(!TARGET_ramips&&USB_SUPPORT):kmod-usb-storage-uas \
	+kmod-fs-ext4 \
	+kmod-fs-exfat \
	+LINUX_5_4:kmod-fs-exfat0 \
	+kmod-fs-vfat \
	+hdparm \
	+libblkid \
	+ntfs3-mount
  PKGARCH:=all
endef

define Package/ntfs3-mount
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  TITLE:=NTFS mount script for Paragon NTFS3 driver
  DEPENDS:=+kmod-fs-ntfs3
#  CONFLICTS:=ntfs-3g
  VARIANT:=ntfs3-mount
  PKGARCH:=all
endef

define Package/automount/description
  A usb autoconfig hotplug script.
endef

define Build/Compile
endef

define Package/automount/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/11-anonmount $(1)/etc/uci-defaults/11-anonmount
	$(INSTALL_BIN) ./files/15-automount $(1)/etc/15-automount
	$(INSTALL_BIN) ./files/zzz-move-automount $(1)/etc/uci-defaults/zzz-move-automount
endef

define Package/ntfs3-mount/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) ./files/mount.ntfs $(1)/sbin/mount.ntfs3
endef

$(eval $(call BuildPackage,automount))
$(eval $(call BuildPackage,ntfs3-mount))

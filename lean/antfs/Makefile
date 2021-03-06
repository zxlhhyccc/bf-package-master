include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=antfs
PKG_RELEASE:=2

PKG_SOURCE_URL:=https://github.com/klukonin/antfs.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2021-02-03
PKG_SOURCE_VERSION:=d4e954cad100a3fa4e374665c91ab7949c1451f3
PKG_MIRROR_HASH:=skip

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define KernelPackage/fs-antfs
	SUBMENU:=Filesystems
	TITLE:=AVM NTFS Read/Write Driver
	FILES:=$(PKG_BUILD_DIR)/antfs.ko
	AUTOLOAD:=$(call AutoLoad,30,antfs,1)
	DEPENDS:=+kmod-nls-base
endef

define KernelPackage/fs-antfs/description
	Kernel module for NTFS Filesytem
endef

MAKE_OPTS:= \
        ARCH="$(LINUX_KARCH)" \
        CROSS_COMPILE="$(TARGET_CROSS)" \
        M="$(PKG_BUILD_DIR)"

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
		$(MAKE_OPTS) \
		CONFIG_ANTFS_FS=m \
		CONFIG_ANTFS_SYMLINKS=y \
		ANTFS_VERSION=07.22-$(call version_abbrev,$(PKG_SOURCE_VERSION)) \
		modules
endef

$(eval $(call KernelPackage,fs-antfs))

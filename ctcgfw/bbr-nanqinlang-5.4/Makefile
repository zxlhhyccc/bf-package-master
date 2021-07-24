include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=tcp-nanqinlang
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
	SUBMENU:=Network Support
	TITLE:=Modified bbr tcp congestion control
	DEPENDS:=@LINUX_5_4
	FILES:=$(PKG_BUILD_DIR)/tcp_nanqinlang.ko
	AUTOLOAD:=$(call AutoLoad,99,tcp-nanqinlang)
	KCONFIG:=
endef

define KernelPackage/$(PKG_NAME)/description
	Kernel module of modified BBR tcp congestion control
endef

EXTRA_KCONFIG:= \
    

EXTRA_CFLAGS:= \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=m,%,$(filter %=m,$(EXTRA_KCONFIG)))) \
	$(patsubst CONFIG_%, -DCONFIG_%=1, $(patsubst %=y,%,$(filter %=y,$(EXTRA_KCONFIG)))) \

MAKE_OPTS:= \
	ARCH="$(LINUX_KARCH)" \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	M="$(PKG_BUILD_DIR)" \
	EXTRA_CFLAGS="$(EXTRA_CFLAGS)" \
	$(EXTRA_KCONFIG)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(MAKE) -C "$(LINUX_DIR)" \
	$(MAKE_OPTS) \
	modules
endef

TCP_NANQINLANG_SYSCTL_CONF:=sysctl-tcp-nanqinlang.conf

define KernelPackage/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/$(TCP_NANQINLANG_SYSCTL_CONF) $(1)/etc/sysctl.d/12-tcp-nanqinlang.conf
endef

$(eval $(call KernelPackage,$(PKG_NAME)))

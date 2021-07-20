include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=tcp-bbrplus
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define KernelPackage/$(PKG_NAME)
	SUBMENU:=Network Support
	TITLE:=Modified bbrplus tcp congestion control
	DEPENDS:=@LINUX_5_4
	FILES:=$(PKG_BUILD_DIR)/tcp_bbrplus.ko
	KCONFIG:=
endef

define KernelPackage/$(PKG_NAME)/description
	BBRplus is an enhanced version of BBR (Bottleneck Bandwidth and RTT).
	Originally introduced by dog250 & cx9208.
	Same as BBR, requires the fq ("Fair Queue") pacing packet scheduler.
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

TCP_BBRPLUS_SYSCTL_CONF:=sysctl-tcp-bbrplus.conf

define KernelPackage/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/sysctl.d
	$(INSTALL_DATA) ./files/$(TCP_BBRPLUS_SYSCTL_CONF) $(1)/etc/sysctl.d/12-tcp-bbrplus.conf
endef

$(eval $(call KernelPackage,$(PKG_NAME)))

# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021 ImmortalWrt.org

include $(TOPDIR)/rules.mk

PKG_NAME:=naiveproxy
PKG_REAL_VERSION:=148.0.7778.96-5
PKG_VERSION:=$(subst -,.,$(PKG_REAL_VERSION))
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_REAL_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/klzgrad/naiveproxy/tar.gz/v$(PKG_REAL_VERSION)?
PKG_HASH:=38ef6ca7a236d5dd2c7a23e488358bd4b516d7b023bffd85690a0a019a1c2c5c
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_REAL_VERSION)

PKG_LICENSE:=BSD 3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=gn/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16

PKG_CONFIG_DEPENDS:= \
	CONFIG_NAIVEPROXY_COMPRESS_UPX

ifneq ($(CONFIG_CPU_TYPE)," ")
  CPU_TYPE:=$(word 1, $(subst +," ,$(CONFIG_CPU_TYPE)))
  CPU_SUBTYPE:=$(word 2, $(subst +, ",$(CONFIG_CPU_TYPE)))
  ifeq ($(CPU_SUBTYPE),)
    CPU_SUBTYPE:=""
  endif
else
  CPU_TYPE:=""
  CPU_SUBTYPE:=""
endif

include $(INCLUDE_DIR)/package.mk

define Package/naiveproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Make a fortune quietly
  URL:=https://github.com/klzgrad/naiveproxy
  DEPENDS:=@!(arc||armeb||loongarch64||mips||mips64||powerpc||TARGET_gemini) +libatomic
endef

define Package/naiveproxy/description
  NaïveProxy uses Chrome's network stack to camouflage traffic with strong
  censorship resistance and low detectability. Reusing Chrome's stack also
  ensures best practices in performance and security.
endef

ifneq ($(CONFIG_CCACHE),)
  export CCACHE_SLOPPINESS=time_macros
  export CCACHE_BASEDIR=$(PKG_BUILD_DIR)/src
  export CCACHE_CPP2=yes
  export naive_ccache_flags=cc_wrapper="$(CCACHE)"
endif

CLANG_VER:=23-init-5669-g8a0be0bc-4
CLANG_FILE:=clang-llvmorg-$(CLANG_VER).tar.xz
define Download/CLANG
	URL:=https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64
	URL_FILE:=$(CLANG_FILE)
	FILE:=$(CLANG_FILE)
	HASH:=bd3a3d7e98cc9037daf24bd7b48f52ba0f0ea5e435c1c707e381034ee4b3c1d6
endef

GN_VER:=6e8dcdebbadf4f8aa75e6a4b6e0bdf89dce1513a
GN_FILE:=gn-git_revision-$(GN_VER).zip
define Download/GN_TOOL
	URL:=https://chrome-infra-packages.appspot.com/dl/gn/gn/linux-amd64/+
	URL_FILE:=git_revision:$(GN_VER)
	FILE:=$(GN_FILE)
	HASH:=3301ff6f7a5b44341019415286de24c1235b1c98ddfb219d2c84320c36ed23d0
endef

PGO_VER:=7778-1777374771-45dd5813b3332165d1d1cd33a478e0a7b948195e-d8efa9b284bd43eccbaf67df2d4a1deaa3c39b89
PGO_FILE:=chrome-linux-$(PGO_VER).profdata
define Download/PGO_PROF
	URL:=https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles
	URL_FILE:=$(PGO_FILE)
	FILE:=$(PGO_FILE)
	HASH:=a916f09998af529b5ed482d89c506eb006d1067bff603684a17778e8b61e682c
endef

# define Build/Prepare
#	$(call Build/Prepare/Default)
#
#	( \
#		pushd $(PKG_BUILD_DIR)/src ; \
#		mkdir -p "chrome/build/pgo_profiles" ; \
#		$(CP) "$(DL_DIR)/$(PGO_FILE)" "chrome/build/pgo_profiles" ; \
#		mkdir -p "third_party/llvm-build/Release+Asserts" ; \
#		$(TAR) -xzf "$(DL_DIR)/$(CLANG_FILE)" -C "third_party/llvm-build/Release+Asserts" ; \
#		echo -e "llvmorg-$(CLANG_VER)" > "third_party/llvm-build/Release+Asserts/cr_build_revision" ; \
#		mkdir -p "gn/out" ; \
#		unzip -o "$(DL_DIR)/$(GN_FILE)" -d "gn/out" ; \
#		popd ; \
#	)
# endef

define Package/naiveproxy/config
menu "NaiveProxy Configuration"
	depends on PACKAGE_naiveproxy

config NAIVEPROXY_COMPRESS_UPX
	bool "Compress executable with UPX"
	default n
	help
	  Compress the naiveproxy binary using UPX to reduce file size.
	  This may increase startup time slightly.
endmenu
endef

define Build/Prepare
	$(call Build/Prepare/Default)

	( \
		pushd $(PKG_BUILD_DIR)/src ; \
		mkdir -p "chrome/build/pgo_profiles" ; \
		$(CP) "$(DL_DIR)/$(PGO_FILE)" "chrome/build/pgo_profiles" ; \
		mkdir -p "third_party/llvm-build/Release+Asserts" ; \
		$(TAR) -xJf "$(DL_DIR)/$(CLANG_FILE)" -C "third_party/llvm-build/Release+Asserts" ; \
		echo -e "llvmorg-$(CLANG_VER)" > "third_party/llvm-build/Release+Asserts/cr_build_revision" ; \
		popd ; \
	)
endef

# define Build/Configure
#	( \
#		pushd "$(PKG_BUILD_DIR)/src" ; \
#		. ../init_env.sh "$(ARCH)" $(CPU_TYPE) $(CPU_SUBTYPE) "$(TOOLCHAIN_DIR)" ; \
#		export naive_flags+=" $$$${naive_ccache_flags}" ; \
#		mkdir -p "out" ; \
#		./gn/out/gn gen "out/Release" --args="$$$${naive_flags}" --script-executable="$(PYTHON)" ; \
#		popd ; \
#	)
# endef

define Build/Configure
	( \
		pushd "$(PKG_BUILD_DIR)/src" ; \
		. ../init_env.sh "$(ARCH)" $(CPU_TYPE) $(CPU_SUBTYPE) "$(TOOLCHAIN_ROOT_DIR)" ; \
		export naive_flags+=" $$$${naive_ccache_flags}" ; \
		mkdir -p "out" ; \
		gn gen "out/Release" --args="$$$${naive_flags}" --script-executable="$(PYTHON)" ; \
		popd ; \
	)
endef

define Build/Compile
	+$(NINJA) -C "$(PKG_BUILD_DIR)/src/out/Release" naive
ifneq ($(CONFIG_NAIVEPROXY_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/src/out/Release/naive
endif
endef

define Package/naiveproxy/conffiles
/etc/config/naiveproxy
endef

define Package/naiveproxy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/out/Release/naive $(1)/usr/bin/naive
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_CONF) $(CURDIR)/files/naiveproxy.config $(1)/etc/config/naiveproxy
	$(INSTALL_BIN) $(CURDIR)/files/naiveproxy.init $(1)/etc/init.d/naiveproxy
endef

$(eval $(call Download,CLANG))
#$(eval $(call Download,GN_TOOL))
$(eval $(call Download,PGO_PROF))

$(eval $(call BuildPackage,naiveproxy))

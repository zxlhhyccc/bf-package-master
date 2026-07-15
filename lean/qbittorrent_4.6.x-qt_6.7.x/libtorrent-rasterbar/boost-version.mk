ifndef BOOST_VERSION_CODE
  BOOST_MAKEFILE := $(if $(wildcard $(TOPDIR)/package/libs/boost/Makefile),\
	$(TOPDIR)/package/libs/boost/Makefile,\
  $(if $(wildcard $(TOPDIR)/feeds/packages/libs/boost/Makefile),\
	$(TOPDIR)/feeds/packages/libs/boost/Makefile,\
  $(firstword $(wildcard $(TOPDIR)/feeds/*/libs/boost/Makefile))))

  BOOST_PKG_VERSION := $(if $(BOOST_MAKEFILE),\
	$(strip $(shell sed -n 's/^PKG_VERSION[[:space:]]*:=//p' $(BOOST_MAKEFILE))))

  BOOST_VERSION_CODE := $(if $(BOOST_PKG_VERSION),\
	$(shell \
		v="$(BOOST_PKG_VERSION)"; \
		IFS='.'; set -- $$v; \
		echo $$(( $${1:-0} * 100000 + $${2:-0} * 100 + $${3:-0} ))),0)

  NEED_BOOST_SYSTEM := $(if $(filter-out 0,$(BOOST_VERSION_CODE)),\
	$(shell [ $(BOOST_VERSION_CODE) -ge 108900 ] && echo y || echo n),n)
endif

Custom openwrt luci-app feeds.
===

How to use
---
1. Add feeds
```bash
cd openwrt/
echo "src-git natelol https://github.com/natelol/natelol.git" >> feeds.conf.default
```

2. Update and Install
```bash
# Update feeds
./scripts/feeds update -a
./scripts/feeds install -a
```

3. make and enjoy
```bash
make menuconfig

make package/feeds/natelol/luci-app-xxxx/compile
```

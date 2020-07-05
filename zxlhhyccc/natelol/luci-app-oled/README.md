luci-app-oled
===
luci-app-oled is an app that drives [ssd1306, 0.91inch, 128*32] oled display tested on NanoPi R2S only.


Features
---
*Display status indicators*  Supported are DATE, TIME, LAN IP, CPU FREQ, CPU TEMP, (TODO)NETSPEED.

*Screensavers* Provides 12 optional screensaver for your preference. Note that SCROLL is highly recommend.

Compile
---

```bash
cd openwrt
git clone https://github.com/natelol/luci-app-oled package/luci-app-oled
make menuconfig
make package/luci-app-oled/compile
```
Enjoy!


 
目前实时网速显示部分并未实现！

# OpenWrt LuCI for Xray

[![Latest release][release_badge]][release_url]

## 简介

本软件包是 [xray][openwrt-xray] 的 LuCI 控制界面,
方便用户控制和使用「透明代理」「SOCKS5 代理」「端口转发」功能.

软件包文件结构:

```
/
├── etc/
│   ├── config/
│   │   └── xray                             // UCI 配置文件
│   │── init.d/
│   │   └── xray                             // init 脚本
│   └── uci-defaults/
│       └── luci-xray                        // uci-defaults 脚本
└── usr/
    ├── bin/
    │   └── xray-rules                                // 生成代理转发规则的脚本
    └── lib/
        └── lua/
            └── luci/                               // LuCI 部分
                ├── controller/
                │   └── xray.lua             // LuCI 菜单配置
                ├── i18n/                           // LuCI 语言文件目录
                │   └── xray.zh-cn.lmo
                └── model/
                    └── cbi/
                        └── xray/
                            ├── general.lua         // LuCI 基本设置
                            ├── servers.lua         // LuCI 服务器列表
                            ├── servers-details.lua // LuCI 服务器编辑
                            └── access-control.lua  // LuCI 访问控制
```

## 依赖

软件包的正常使用需要依赖 `iptables` 和 `ipset`.  
软件包不显式依赖 `xray`, 会根据用户添加的可执行文件启用相应的功能.  
**GFW-List 模式 正常使用需要依赖 [dnsmasq-extra][openwrt-dnsmasq-extra], 其中包括`DNS防污染`和`GFW-List`**  
可执行文件可通过安装 [openwrt-xray][openwrt-xray] 中提供的 `xray` 获得.  
只有当文件存在时, 相应的功能才可被使用, 并显示相应的 LuCI 设置界面.

| 可执行文件 | 可选 | 功能     | TCP 协议 | UDP 协议                           |
| ---------- | ---- | -------- | -------- | ---------------------------------- |
| `xray`     | 是   | 透明代理 | 支持     | 需安装 `iptables-mod-tproxy`, `ip` |

注: 可执行文件在 `$PATH` 环境变量所表示的搜索路径中, 都可被正确调用.

## 配置

软件包的配置文件路径: `/etc/config/xray`  
此文件为 UCI 配置文件, 配置方式可参考 [Wiki -> Use-UCI-system][use-uci-system] 和 [OpenWrt Wiki][uci]  
透明代理的访问控制功能设置可参考 [Wiki -> LuCI-Access-Control][luci-access-control]

## 编译

从 OpenWrt 的 [SDK][openwrt-sdk] 编译

```bash
# 解压下载好的 SDK
tar xjf OpenWrt-SDK-ar71xx-for-linux-x86_64-gcc-4.8-linaro_uClibc-0.9.33.2.tar.bz2
cd OpenWrt-SDK-ar71xx-*
# Clone 项目
git clone https://github.com/honwen/luci-app-xray.git package/luci-app-xray
# 编译 po2lmo (如果有po2lmo可跳过)
pushd package/luci-app-xray/tools/po2lmo
make && sudo make install
popd
# 选择要编译的包 LuCI -> 3. Applications
make menuconfig
# 开始编译
make package/luci-app-xray/compile V=99
```

[release_badge]: https://img.shields.io/github/release/honwen/luci-app-xray.svg
[release_url]: https://github.com/honwen/luci-app-xray/releases
[openwrt-xray]: https://github.com/honwen/openwrt-precompiled-feeds
[openwrt-sdk]: https://wiki.openwrt.org/doc/howto/obtain.firmware.sdk
[xray-rules]: https://github.com/xray/luci-app-xray/wiki/Instruction-of-xray-rules
[use-uci-system]: https://github.com/xray/luci-app-xray/wiki/Use-UCI-system
[uci]: https://wiki.openwrt.org/doc/uci
[luci-access-control]: https://github.com/xray/luci-app-xray/wiki/LuCI-Access-Control
[openwrt-dnsmasq-extra]: https://github.com/honwen/openwrt-dnsmasq-extra

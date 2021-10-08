# luci-app-syncthing

请配合 [OpenWrt 官方 syncthing](https://github.com/openwrt/packages/tree/master/utils/syncthing) 使用。

**请勿使用 Lean 版或 Lienol 版 Syncthing。** 如需使用，请用对应仓库内的 luci-app-syncthing。

### 附

如需升级 OpenWrt 官方 syncthing 版本，请修改 syncthing 插件的 [Makefile](https://github.com/openwrt/packages/blob/master/utils/syncthing/Makefile)：

- 第一处：第4行

  https://github.com/openwrt/packages/blob/master/utils/syncthing/Makefile#L4

  前往 [Syncthing Release](https://github.com/syncthing/syncthing/releases) 页面查看最新版本号 **（不包含前导v）**

- 第二处：第9行

  https://github.com/openwrt/packages/blob/master/utils/syncthing/Makefile#L9

  将其修改为 `PKG_HASH:=skip`

此外，为防止升级后数据库破损，建议升级时不保留数据库，具体如下：

- 删除 [Makefile 第48行](https://github.com/openwrt/packages/blob/master/utils/syncthing/Makefile#L48)，替换为：

  ```
  /etc/syncthing/cert.pem
  /etc/syncthing/config.xml
  /etc/syncthing/https-cert.pem
  /etc/syncthing/https-key.pem
  /etc/syncthing/key.pem
  ```

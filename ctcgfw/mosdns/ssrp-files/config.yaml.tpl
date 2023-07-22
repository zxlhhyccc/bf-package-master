log:
  level: error
  file: '/tmp/mosdns.log'

data_providers:
  - tag: geosite
    file: "/usr/share/v2ray/geosite.dat"
    auto_reload: true
  - tag: geoip
    file: "/usr/share/v2ray/geoip.dat"
    auto_reload: true

plugins:
  # 缓存
  - tag: lazy_cache
    type: cache
    args:
      size: 10240
      lazy_cache_ttl: 86400

  # ipset 写入应答 IP 到系统 ipset
  - tag: blacklist
    type: 'ipset'
    args:
      set_name4: 'blacklist'   # 如果非空，存放 ipv4 地址到这个表。这个表属性 family 需为 `inet`。
      set_name6: ''   # 如果非空，存放 ipv6 地址到这个表。这个表属性 family 需为 `inet6`。
      mask4: 24       # 写入 ipv4 地址时使用的掩码。默认: 24。
      mask6: 32       # 写入 ipv6 地址时使用的掩码。默认: 32。

  # ipset 写入应答 IP 到系统 ipset，用于使用主机名进行连接的场合
  - tag: whitelist
    type: 'ipset'
    args:
      set_name4: 'whitelist'   # 如果非空，存放 ipv4 地址到这个表。这个表属性 family 需为 `inet`。
      set_name6: ''   # 如果非空，存放 ipv6 地址到这个表。这个表属性 family 需为 `inet6`。
      mask4: 32       # 写入 ipv4 地址时使用的掩码。默认: 24。
      mask6: 32       # 写入 ipv6 地址时使用的掩码。默认: 32。

  # 转发至本地服务器的插件
  - tag: forward_local
    type: fast_forward
    args:
      upstream:
        - addr:   119.29.29.29
        - addr:   101.226.4.6
        - addr:   223.5.5.5
          trusted: true # 是否是可信服务器

  # 转发至远程服务器的插件
  - tag: forward_remote
    type: fast_forward
    args:
      upstream:
        - addr:   tcp://1.1.1.1
        - addr:   tcp://76.76.19.19
        - addr:   tcp://208.67.222.222
          trusted: true # 是否是可信服务器
  - tag: is_gate
    type: response_matcher
    args:
      ip:
        - "255.255.255.255"

  # 匹配本地域名的插件
  - tag: query_is_local_domain
    type: query_matcher
    args:
      domain:
        - 'provider:geosite:cn'
        #- 'provider:geosite:apple-cn'
        #- 'provider:geosite:google-cn'

  # 匹配非本地域名的插件
  - tag: query_is_non_local_domain
    type: query_matcher
    args:
      domain:
        - 'provider:geosite:geolocation-!cn'

  # 匹配本地 IP 的插件
  - tag: response_has_local_ip
    type: response_matcher
    args:
      ip:
        - 'provider:geoip:cn'

  # 匹配广告域名的插件
  #- tag: query_is_ad_domain
  #  type: query_matcher
  #  args:
  #    domain:
  #      - 'provider:geosite:category-ads-all'

  # 主要的运行逻辑插件
  # sequence 插件中调用的插件 tag 必须在 sequence 前定义，
  # 否则 sequence 找不到对应插件。
  - tag: main_sequence
    type: sequence
    args:
      exec:
        - lazy_cache
        #- _no_ecs

        # 屏蔽广告域名
        - if: query_is_ad_domain
          exec:
            - _new_nxdomain_response
            - _return

        - primary:
            - forward_local
            - if: "is_gate"
              exec:
                - whitelist
                - _return
            - if: "response_has_local_ip"
              exec:
                - _return
            - if: "!response_has_local_ip"
              exec:
                - _drop_response
          secondary:
            - _no_ecs
            - _prefer_ipv4
            - forward_remote
            - if: "!response_has_local_ip && !is_gate"
              exec:
                - blacklist
          fast_fallback: 150
          always_standby: true

servers:
  - exec: main_sequence
    listeners:
      - protocol: udp
        addr: :5335
      - protocol: tcp
        addr: :5335
      # - protocol: udp
      #   addr: "[::1]:5335"
      # - protocol: tcp
      #   addr: "[::1]:5335"

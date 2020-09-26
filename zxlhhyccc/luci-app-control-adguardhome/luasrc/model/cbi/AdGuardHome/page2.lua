--mod by wulishui 201911107

local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local gport = uci:get_first("AdGuardHome", "AdGuardHome", "port") or 3000
local m,s

m = Map("AdGuardHome", translate("<font style='color:green'>AdGuard Home帮助</font>"))
m.description = translate("")

s = m:section(TypedSection, "AdGuardHome")
s.anonymous=true
s.addremove=false
s.description = translate("1.启用后web服务监听端口3003、DNS服务监听端口54，作为dnsmasq上游服务并且在<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("网络->DHCP/DNS->DNS 转发").." \" onclick=\"window.open('http://'+window.location.hostname+'/cgi-bin/luci/admin/network/dhcp')\"/>处生成一条转发列表：127.0.0.1#54 。<br/><br/>2.如要DNSforwarder与adguardhome串联使用：......<font style='color:brown'>外网->DNSforwarder<-端口5053->adguardhome<-端口54->dnsmasq<-端口53-><-内网</font>......<br /><br />&nbsp;将adguardhome的<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("上游 DNS 服务器").." \" onclick=\"window.open('http://'+window.location.hostname+':"..gport.."/#dns')\"/>改为 <font style='color:blue'>127.0.0.1:5053</font> 即可，这样既能使用DNSforwarder的IP黑名单功能又能使用adguardhome的去广告防护功能。<br/><br />3.如需跳过dnsmasq作为唯一DNS解析服务使用则：将<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("防火墙 -> 自定义规则").." \" onclick=\"window.open('http://'+window.location.hostname+'/cgi-bin/luci/admin/network/firewall/custom')\"/>中的两项53端口转发改为54即可。<br /><br />&nbsp;如遇到smb无法识别路径，在adguardhome自定义规则添加“192.168.18.1 iou.lan”。<br /><br />4.adguardhome详细配置说明可在https://github.com/AdguardTeam/AdGuardHome/wiki/Configuration#upstreams-for-domains浏览。")

return m



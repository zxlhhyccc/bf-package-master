--by wulishui 20191216

local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

local button = ""
local state_msg = ""
local m,s

local gport = uci:get_first("AdGuardHome", "AdGuardHome", "port") or 3000

local running=(luci.sys.call("pidof AdGuardHome > /dev/null") == 0)
if running then
        state_msg = "<b><font color=\"green\">" .. translate("～正在运行～") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("AdGuardHome在睡觉觉zZZ") .. "</font></b>"
end

if running  then
	button = "<br/><br/>---<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("打开管理界面").." \" onclick=\"window.open('http://'+window.location.hostname+':"..gport.."')\"/>---"
end

m = Map("AdGuardHome", translate("AdGuard Home"))
m.description = translate("<font style='color:green'>AdGuard Home是一个可在特定网络范围内拦截所有广告和跟踪器的DNS服务器。详情见：<a href=\"https://adguard.com/zh_cn/adguard-home/overview.html\" target=\"_blank\">官方网站</a></font>".. button .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br/>")

s = m:section(TypedSection, "AdGuardHome")
s.anonymous=true
s.addremove=false

enabled = s:option(Flag, "enabled", translate("启用"))
enabled.default = 0
enabled.rmempty = true

----------------------
enabled = s:option(ListValue, "work_mode", translate("工作模式"))
enabled.description = translate("*改变工作模式会清空DNS查询记录以及使AdGuardHome进程重启。</br>*模式3、4会导致ssr-plus失效、模式4会导致samba无法发布组播。</br>*模式5要在ssr设“DNS解析方式”为“使用本机端口为5335的DNS服务”。")
enabled:value("1", translate("1.自由设置模式（要留意“高级”里的DNS监听端口配置）"))
enabled:value("2", translate("2.作为dnsmasq上游服务（dnsmasq监听53后转54，AdGuardHome监听54，端口无影射）"))
enabled:value("3", translate("3.跳过dnsmasq解析DNS（端口54影射至53，AdGuardHome监听54，dnsmasq仍监听网关内部53）"))
enabled:value("4", translate("4.作为唯一DNS解析服务（dnsmasq监听无效的55，AdGuardHome监听53，端口无影射）"))
enabled:value("5", translate("5.作为dnmasq上游、ssr DNS解析（dnsmasq监听53后转5335，AdGuardHome监听5335，端口无影射）"))
enabled:value("6", translate("6.跳过dndmasq、作为ssr DNS解析（端口5335影射至53，AdGuardHome监听5335，dnsmasq仍监听网关内部53）"))
enabled.default = 2
----------------------

setport =s:option(Value,"port",translate("WEB端口"))
setport.description = translate("如在向导中设了其它端口，只需要重启一次AdGuardHome即可改变。")
setport.placeholder=3003
setport.default=3003
setport.datatype="port"
setport.rmempty=true

return m



local a, t, e
local button = ""
local state_msg = ""
local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local ifaces = sys.net:devices()

local running=(luci.sys.call("iptables -L FORWARD|grep WEBURL >/dev/null") == 0)
local ruleswt=(luci.sys.call("[ $(iptables -L WEBURL 2>/dev/null|wc -l) == $(cat /etc/config/weburl 2>/dev/null|grep -c 'option enable .1.'|awk '{print$1+2}') ] 2>/dev/null") == 0)
local lucimode=(luci.sys.call("[ $(uci get weburl.@basic[0].lucimode 2>/dev/null) == 1 ] 2>/dev/null") == 0)

local button = ""
local state_msg = ""
if running and ruleswt then
state_msg = "<b><font color=\"green\">" .. translate("正常运行") .. "</font></b>"
elseif running and not ruleswt then
state_msg = "<b><font color=\"green\">" .. translate("已运行但规则数量不符，请在终端输入 iptables -L WEBURL 检查") .. "</font></b>"
elseif not running and ruleswt then
state_msg = "<b><font color=\"red\">" .. translate("已运行但主链丢失，过滤功能没有生效，请重新运行") .. "</font></b>"
else
state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end
a = Map("weburl", translate("网址过滤/关键字过滤/MAC黑名单/时间控制/端口控制"), translate("利用iptables进行数据包过滤以禁止符合设定条件的用户连接互联网的工具软件。" .. button  .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />"))
t = a:section(TypedSection, "basic", translate(""), translate(""))
t.anonymous = true
e = t:option(Flag, "enabled", translate("开启功能"))
e.rmempty = false
e = t:option(ListValue, "algos", translate("过滤力度"))
e:value("bm", "一般过滤")
e:value("kmp", "强效过滤---效果更好、耗用资源更多")
e.default = "kmp"

if lucimode then
simple = t:option(Button, "simple", translate("简单界面"), translate("点击切换到简单界面"))
function simple.write()
   o.exec("uci set weburl.@basic[0].lucimode='0'")
   o.exec("uci commit weburl")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "weburl"))
end
else
complex = t:option(Button, "complex", translate("复杂界面"), translate("点击切换到复杂界面---可控制接口、端口"))
function complex.write()
   o.exec("uci set weburl.@basic[0].lucimode='1'")
   o.exec("uci commit weburl")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "weburl"))
end
end

t = a:section(TypedSection, "macbind", translate(""), translate("<b><font color=\"black\">规则说明：</font> </b>条件可单独或组合使用。如仅选接口（时间、星期可选）则仅控制经该接口接入的用户；如仅指定“MAC黑名单”（时间、星期可选）则为MAC黑名单规则；如仅指定“关键字/url”（MAC、时间、星期可选）则为关键字过滤规则；如仅指定“端口”（MAC、时间、星期可选）则为端口控制规则。端口可以是单端口或范围如5000:5100或多端口5100,5110或两者都使用。如仅指定时间、星期，则所有客户端都只能在控制时间段外联网。"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e.default = '1'
if lucimode then
e = t:option(Value, "interface", translate("接口<font color=\"green\">(可留空)</font>&nbsp;"))
for _, iface in ipairs(ifaces) do
if not (iface:match("_ifb$") or iface:match("^ifb*")) then
	if ( iface:match("^eth*") or iface:match("^wlan*") or iface:match("^usb*") or iface:match("^br*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		e:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
end
e.rmempty = true
end
e = t:option(Value, "macaddr", translate("&nbsp;&nbsp;黑名单MAC<font color=\"green\">(留空=所有客户端)</font>&nbsp;&nbsp;"))
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)
if lucimode then
e = t:option(ListValue, "proto", translate("端口协议"))
e.rmempty = false
e.default = 'tcp'
e:value("tcp", translate("TCP"))
e:value("udp", translate("UDP"))
e:value("icmp", translate("ICMP"))
e = t:option(Value, "sport", translate("源端口"))
e.rmempty = true
e = t:option(Value, "dport", translate("目的端口"))
e.rmempty = true
end
    function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "时间格式必须为 HH:MM 或者留空"
        end
    end
e = t:option(Value, "timeon", translate("起控时间"))
e.placeholder = "00:00"
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e = t:option(Value, "timeoff", translate("停控时间"))
e.placeholder = "00:00"
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e = t:option(MultiValue, "daysofweek", translate("星期<font color=\"green\">(至少选一天，某天不选则该天不进行控制)</font>"))
e.optional = false
e.rmempty = false
e.default = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
e:value("Monday", translate("一"))
e:value("Tuesday", translate("二"))
e:value("Wednesday", translate("三"))
e:value("Thursday", translate("四"))
e:value("Friday", translate("五"))
e:value("Saturday", translate("六"))
e:value("Sunday", translate("日"))
e = t:option(Value, "keyword", translate("关键词/URL<font color=\"green\">(可留空)</font>"))
e.rmempty = true
return a




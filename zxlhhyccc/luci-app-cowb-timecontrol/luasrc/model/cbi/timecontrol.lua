local a, t, e
local button = ""
local state_msg = ""
local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local sys = require "luci.sys"

local button = ""
local state_msg = ""

if luci.sys.call("pidof timecontrold >/dev/null") == 0 then
state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end

a = Map("timecontrol", translate("时长控制"), translate("利用iptables控制用户访问网络时长的软件，达到时长后强制断网休息一段时长后才能再次联网。" .. button  .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />"))

t = a:section(TypedSection, "basic")
t.anonymous = true

o = t:option(Flag, "enabled", translate("开启功能"))
o.rmempty = false

t = a:section(TypedSection, "user", "", translate("* “放行时长”、“禁止时长”任一留空则禁用时长控制，仅时间控制起效；时长控制与时间控制是“与”关系，即在放行开始后才会进行时段控制；如“放行开始”、“放行结束”都留空则全天候时长控制。"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

o = t:option(Flag, "enable", translate("开启"))
o.rmempty = false
o.default = '1'

o = t:option(Value, "ipaddr", translate("MAC/IP 地址"))
sys.net.mac_hints(function(mac, name)
	o:value(mac, "%s (%s)" %{ mac, name })
end)
o.rmempty = false

o = t:option(Value, "enabledtime", translate("放行时长"))
o.datatype = "uinteger"
o.placeholder = translate("minute")
o.rmempty = true

o = t:option(Value, "disabledtime", translate("禁止时长"))
o.datatype = "uinteger"
o.placeholder = translate("minute")
o.rmempty = true

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

o = t:option(Value, "timeon", translate("放行开始"))
o.placeholder = "17:00"
o.validate = validate_time
o.rmempty = true

o = t:option(Value, "timeoff", translate("放行结束"))
o.placeholder = "22:00"
o.validate = validate_time
o.rmempty = true

o = t:option(MultiValue, "daysofweek", translate("星期<font color=\"green\">(至少选一天，某天不选则该天不允许放行)</font>"))
o.optional = false
o.rmempty = false
o.default = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
o:value("Monday", translate("一"))
o:value("Tuesday", translate("二"))
o:value("Wednesday", translate("三"))
o:value("Thursday", translate("四"))
o:value("Friday", translate("五"))
o:value("Saturday", translate("六"))
o:value("Sunday", translate("日"))

o = t:option(Value, "comment", translate("Comment"))
o.placeholder = translate("Comment")
o.rmempty = true

return a



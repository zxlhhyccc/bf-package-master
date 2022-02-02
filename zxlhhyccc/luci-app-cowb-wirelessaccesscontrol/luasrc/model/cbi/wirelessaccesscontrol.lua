local o = require "luci.sys"
local a, t, e
local button = ""
local state_msg = ""

local running=(luci.sys.call("grep -q 'option macfilter' /etc/config/wireless") == 0)
if running then
        state_msg = "<b><font color=\"green\">" .. translate("正在运行") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("没有运行") .. "</font></b>"
end

a = Map("wirelessaccesscontrol", translate("Wireless access control"), translate("" .. button .. "" .. translate("运行状态").. " : "  .. state_msg .. "<br />"))

t = a:section(TypedSection, "basic")
t.anonymous = true

e = t:option(Flag, "enabled", translate("enable"))

e = t:option(ListValue, "macfilter", translate("Mode"))
e:value("deny", "黑名单模式")
e:value("allow", "白名单模式")
e.default = "deny"

local sl = luci.util.execi("uci show wireless |grep 'wifi-iface' |awk -F '[.=]' '{print $2}'") or { }
e = t:option(DynamicList, "wifi_iface", translate("无线"))
e:value("all", "-- All --")
for v in sl do
    e:value((v or "nil"))
end

t = a:section(TypedSection, "macbind", translate("Client"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(Flag, "enable", translate("enable"))
e.rmempty = false
e.default = "1"

e = t:option(Value, "macaddr", translate("MAC"))
e.rmempty = false
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)

o = t:option(Value, "comment", translate("Comment"))
o.placeholder = translate("Comment")

return a



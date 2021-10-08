require("nixio.fs")

m = Map("v2raya")
m.title = translate("v2rayA")
m.description = translate("Simple v2rayA switch.")

m:section(SimpleSection).template  = "v2raya/v2raya_status"

s = m:section(TypedSection, "v2raya")
s.addremove = false
s.anonymous = true

o = s:option(Flag, "enabled", translate("Enable"))
o.rmempty = false

o = s:option(Value, "port", translate("Port"))
o.datatype = "port"
o.placeholder = "2017"
o.default = "2017"
o.rmempty = false

o = s:option(Value, "config", translate("v2rayA configuration directory"))
o.default = '/etc/v2raya'

local e = luci.http.formvalue("cbi.apply")
o.inputstyle = "reload"
    luci.sys.exec("/etc/init.d/v2raya restart >/dev/null 2>&1 &")


return m

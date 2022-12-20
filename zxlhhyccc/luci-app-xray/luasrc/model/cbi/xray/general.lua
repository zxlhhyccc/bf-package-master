-- Copyright (C) 2014-2018 Jian Chang <aa65535@live.com>
-- Copyright (C) 2020-2022 honwen <https://github.com/honwen>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local xray = "xray"
local uci = luci.model.uci.cursor()
local servers = {}
local strategy = {
	"random",
	"leastPing",
	"leastLoad",
}

local function has_bin(name)
	return luci.sys.call("command -v %s >/dev/null" %{name}) == 0
end

local function has_udp_relay()
	return luci.sys.call("lsmod | grep -q TPROXY && command -v ip >/dev/null") == 0
end

if not has_bin("xray") then
	return Map(xray, "%s - %s" %{translate("Xray"),
		translate("General Settings")}, '<b style="color:red">xray binary file not found.</b>')
end

local function is_running(name)
	return luci.sys.call("pgrep -f '%s' >/dev/null" %{name}) == 0
end

local function get_status(name)
	return is_running(name) and translate("RUNNING") or translate("NOT RUNNING")
end

uci:foreach(xray, "servers", function(s)
	if s.server and s.server_port then
		servers[#servers+1] = {name = s[".name"], alias = s.alias or "%s:%s" %{s.server, s.server_port}}
	end
end)

m = Map(xray, "%s - %s" %{translate("Xray"), translate("General Settings")})
m.template = "xray/general"

-- [[ Running Status ]]--
s = m:section(TypedSection, "general", translate("Running Status"))
s.anonymous = true

o = s:option(DummyValue, "_xray_status", translate("Xray"))
o.value = "<span id=\"_xray_status\">%s</span>" %{get_status("bin/xray")}
o.rawhtml = true

-- [[ General Config ]]--
s = m:section(TypedSection, "general", translate("Global Settings"))
s.anonymous = true

o = s:option(Value, "startup_delay", translate("Startup Delay"))
o:value(0, translate("Not enabled"))
for _, v in ipairs({3, 5, 10, 15, 25, 40}) do
	o:value(v, translatef("%u seconds", v))
end
o.datatype = "uinteger"
o.default = 0
o.rmempty = false

o = s:option(DynamicList, "server", translate("Server"))
o:value("nil", translate("Disable"))
for _, s in ipairs(servers) do o:value(s.name, s.alias) end
o.default = "nil"
o.rmempty = false

o = s:option(Value, "strategy", translate("Balancer Strategy"))
for _, v in ipairs(strategy) do o:value(v, v:upper()) end
o.default = 'leastPing'
o.rmempty = false

o = s:option(Flag, "no_dns_injection", translate("Disable DNS Auto-Injection"))
o.rmempty = false

-- [[ Transparent Proxy ]]--
s = m:section(TypedSection, "transparent_proxy", translate("Transparent Proxy"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1234
o:depends('enable', '1')

o = s:option(Flag, "no_healthcheck", translate("Disable HealthCheck"))
o.rmempty = false

-- [[ HTTP Proxy ]]--
s = m:section(TypedSection, "http_proxy", translate("HTTP Proxy"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o:depends('enable', '1')

-- [[ SOCKS5 Proxy ]]--
s = m:section(TypedSection, "socks5_proxy", translate("SOCKS5 Proxy"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 1080
o:depends('enable', '1')

-- [[ Port Forward ]]--
s = m:section(TypedSection, "port_forward", translate("Port Forward"))
s.anonymous = true

o = s:option(Flag, "enable", translate("Enable"))
o.rmempty = false

o = s:option(Value, "local_port", translate("Local Port"))
o.datatype = "port"
o.default = 5300
o:depends('enable', '1')

o = s:option(Value, "destination", translate("Destination"))
o.default = "8.8.4.4:53"
o:depends('enable', '1')

return m

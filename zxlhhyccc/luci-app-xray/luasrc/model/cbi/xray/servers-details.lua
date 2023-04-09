-- Copyright (C) 2016-2017 Jian Chang <aa65535@live.com>
-- Copyright (C) 2020-2023 honwen <https://github.com/honwen>
-- Licensed to the public under the GNU General Public License v3.

local m, s, o
local xray = "xray"
local sid = arg[1]
local protocols = {
	"socks",
	"vless",
	"trojan",
	"shadowsocks",
}
local securitys = {
	"h2@reality",
	"xtls-vision@reality",
	"xtls-splice",
	"xtls-direct",
	"xtls-vision",
	"tls",
	"wss",
	"quic",
}
local encrypts = {
	"aes-256-gcm",
	"aes-128-gcm",
	"chacha20-ietf-poly1305",
	"2022-blake3-aes-128-gcm",
	"2022-blake3-aes-256-gcm",
	"2022-blake3-chacha20-poly1305",
	"rc4-md5",
	"aes-128-cfb",
	"aes-192-cfb",
	"aes-256-cfb",
	"aes-128-ctr",
	"aes-192-ctr",
	"aes-256-ctr",
	"camellia-128-cfb",
	"camellia-192-cfb",
	"camellia-256-cfb",
	"chacha20-ietf",
	"none",
}

m = Map(xray, "%s - %s" %{translate("Xray"), translate("Edit Server")})
m.redirect = luci.dispatcher.build_url("admin/services/xray/servers")
m.sid = sid
m.template = "xray/servers-details"

if m.uci:get(xray, sid) ~= "servers" then
	luci.http.redirect(m.redirect)
	return
end

-- [[ Edit Server ]]--
s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias(optional)"))
o.rmempty = true

o = s:option(ListValue, "protocol", translate("Protocol"))
for _, v in ipairs(protocols) do o:value(v, v:upper()) end
o.default = 'vless'
o.rmempty = false

o = s:option(Value, "server", translate("Server Address"))
o.datatype = "host"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.rmempty = false

o = s:option(Value, "server_name", translate("Server Name"))
o:depends('protocol', 'vless')
o:depends('protocol', 'trojan')
o.datatype = "host"
o.rmempty = true

o = s:option(Value, "id", translate("ID/AUTH"))
o:depends('protocol', 'vless')
o:depends('protocol', 'trojan')
o:depends('protocol', 'shadowsocks')
o.password = true

-- [[ vless/trojan ]]--
o = s:option(ListValue, "security", translate("Security"))
for _, v in ipairs(securitys) do o:value(v, v:upper()) end
o:depends('protocol', 'vless')
o:depends('protocol', 'trojan')
o.default = 'xtls-vision@reality'
o.rmempty = false

o = s:option(Value, "ws_path", translate("Websocket Path"))
o:depends('security', 'wss')
o.placeholder = "/"
o.rmempty = false
-- [[ vless/trojan ]]--

-- [[ vless@reality ]]--
o = s:option(Value, "public_key", translate("Public Key"))
o:depends('security', 'xtls-vision@reality')
o:depends('security', 'h2@reality')
o.rmempty = false

o = s:option(Value, "short_id", translate("Short ID"))
o:depends('security', 'xtls-vision@reality')
o:depends('security', 'h2@reality')
o.rmempty = true
-- [[ vless@reality ]]--

-- [[ shadowsocks ]]--
o = s:option(ListValue, "method", translate("Encrypt Method"))
for _, v in ipairs(encrypts) do o:value(v, v:upper()) end
o:depends('protocol', 'shadowsocks')
o.rmempty = false

o = s:option(Value, "plugin", translate("Plugin Name"))
o:depends('protocol', 'socks')
o:depends('protocol', 'shadowsocks')
-- o.placeholder = "eg: v2ray-plugin"
o.rmempty = true

o = s:option(Value, "plugin_opts", translate("Plugin Arguments"))
o:depends('protocol', 'socks')
o:depends('protocol', 'shadowsocks')
-- o.placeholder = "eg: tls;host=www.bing.com;path=/websocket"
o.rmempty = true
-- [[ shadowsocks ]]--

return m

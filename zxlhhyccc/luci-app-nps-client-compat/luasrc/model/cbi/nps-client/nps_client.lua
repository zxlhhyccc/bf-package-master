m = Map("nps-client")
m.title = translate("Nps Client")
m.description = translate("Nps is a fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet.")

m:section(SimpleSection).template = "nps-client/nps-client_status"

s = m:section(TypedSection, "nps-client")
s.addremove = false
s.anonymous = true

s:tab("setting", translate("Basic Setting"))
enable = s:taboption("setting", Flag, "enabled", translate("Enable"))
enable.rmempty = false

server = s:taboption("setting", Value, "server_addr", translate("Server"))
server.datatype = "host"
server.optional = false
server.rmempty = false

port = s:taboption("setting", Value, "server_port", translate("Port"))
port.datatype = "port"
port.default = "8024"
port.optional = false
port.rmempty = false

protocol = s:taboption("setting", ListValue, "protocol", translate("Protocol Type"))
protocol.default = "tcp"
protocol:value("tcp", translate("TCP Protocol"))
protocol:value("kcp", translate("KCP Protocol"))

auto_reconnection = s:taboption("setting", ListValue, "auto_reconnection", translate("Auto Reconnection"))
auto_reconnection.description = translate("Auto reconnect to the server when the connection is down.")
auto_reconnection.default = "true"
auto_reconnection:value("true", translate("True"))
auto_reconnection:value("false", translate("False"))

vkey = s:taboption("setting", Value, "vkey", translate("vkey"))
vkey.optional = false
vkey.password = true
vkey.rmempty = false

compress = s:taboption("setting", Flag, "compress", translate("Enable Compression"), translate("The contents will be compressed to speed up the traffic forwarding speed, but this will consume some additional cpu resources."))
compress.default = "1"
compress.rmempty = false

crypt = s:taboption("setting", Flag, "crypt", translate("Enable Encryption"), translate("Encrypted the communication between Npc and Nps, will effectively prevent the traffic intercepted."))
crypt.default = "1"
crypt.rmempty = false

log_level = s:taboption("setting", ListValue, "log_level", translate("Log Level"))
log_level:value(0, translate("Emergency"))
log_level:value(1, translate("Alert"))
log_level:value(2, translate("Critical"))
log_level:value(3, translate("Error"))
log_level:value(4, translate("Warning"))
log_level:value(5, translate("Notice"))
log_level:value(6, translate("Info"))
log_level:value(7, translate("Debug"))
log_level.default = "3"

return m


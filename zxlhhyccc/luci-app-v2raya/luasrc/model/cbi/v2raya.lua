-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.

require("nixio.fs")

m = Map("v2raya", translate("Simple v2rayA switch."))

m:section(SimpleSection).template  = "v2raya/v2raya_status"

s = m:section(TypedSection, "v2raya")
s.anonymous = true
s.addremove=false

o = s:option(Flag, "enabled", translate("Enabled"))
o.default = 0
o.rmempty = false

o = s:option(Value, "address", translate("GUI access address"))
o.description = translate("Use 0.0.0.0:2017 to monitor all access.")
o.default = "http://0.0.0.0:2017"
o.rmempty = false

o = s:option(Value, "config", translate("v2rayA configuration directory"))
o.rmempty = '/etc/v2raya'

o = s:option(Value, "ipv6_support", translate("Ipv6 Support"))
o.description = translate("Make sure your IPv6 network works fine before you turn it on.")
o:value("auto", translate("AUTO"))
o:value("on", translate("ON"))
o:value("off", translate("OFF"))
o.default = auto

o = s:option(Value, "log_file", translate("Log file"))
o.default = "/tmp/v2raya.log"

o = s:option(ListValue, "log_level", translate("Log Level"))
o:value("trace",translate("Trace"))
o:value("debug",translate("Debug"))
o:value("info",translate("Info"))
o:value("warn",translate("Warning"))
o:value("error",translate("Error"))
o.default = "Info"

o = s:option(Value, "log_max_days", translate("Log Keepd Max Days"))
o.description = translate("Maximum number of days to keep log files.")
o.datatype = "uinteger"
o.default = "3"

o = s:option(Value, "log_disable_color", translate("Disable log color"))
o.enabled = "true"
o.disabled = "false"
o.default = "1"

o = s:option(Value, "log_disable_timestamp", translate("Log disable timestamp"))
o.enabled = "true"
o.disabled = "false"
o.default = "0"

o = s:option(Value, "vless_grpc_inbound_cert_key", translate("Upload certificate"))
o.description = translate("Specify the certification path instead of automatically generating a self-signed certificate.")
o.template = "v2raya/v2raya_certupload"

cert_dir = "/etc/v2raya/"
local path

luci.http.setfilehandler(function(meta, chunk, eof)
	if not fd then
		if (not meta) or (not meta.name) or (not meta.file) then
			return
		end
		fd = nixio.open(cert_dir .. meta.file, "w")
		if not fd then
			path = translate("Create upload file error.")
			return
		end
	end
	if chunk and fd then
		fd:write(chunk)
	end
	if eof and fd then
		fd:close()
		fd = nil
		path = '/etc/v2raya/' .. meta.file .. ''
	end
end)
if luci.http.formvalue("upload") then
	local f = luci.http.formvalue("ulfile")
	if #f <= 0 then
		path = translate("No specify upload file.")
	end
end

o = s:option(Value, "vless_grpc_inbound_cert_key", translate("Upload Certificate Path"))
o.default = "/etc/v2raya/cert.crt,/etc/v2raya/cert.key"


o.inputstyle = "reload"
    luci.sys.exec("/etc/init.d/v2raya start >/dev/null 2>&1 &")

return m

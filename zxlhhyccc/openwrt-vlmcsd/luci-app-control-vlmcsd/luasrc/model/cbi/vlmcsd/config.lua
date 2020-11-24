local fs = require "nixio.fs"
local conffile = "/etc/vlmcsd.ini"

f=SimpleForm("custom")
t=f:field(TextValue,"conf")
t.rmempty=true
t.rows=13
t.description=translate("This file is /etc/vlmcsd.ini")
function t.cfgvalue()
	return fs.readfile(conffile) or ""
end

function f.handle(self,state,data)
	if state == FORM_VALID then
		if data.conf then
			fs.writefile(conffile,data.conf:gsub("\r\n","\n"))
			luci.sys.exec("/etc/init.d/vlmcsd restart")
		end
	end
	return true
end

return f

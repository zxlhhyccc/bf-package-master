local fs=require "nixio.fs"
local white="/etc/bypass/white.list"
local black="/etc/bypass/black.list"
local netflix="/etc/bypass/netflix.list"
local oversea="/etc/bypass/oversea.list"
local preload="/etc/bypass/preload.list"

f=SimpleForm("custom",translate("Domain List"))

t=f:field(TextValue,"A",translate("Bypass Domain List"))
t.rmempty=true
t.rows=8
t.description=translate("Bypass Domain List")
function t.cfgvalue()
	return fs.readfile(white) or ""
end

t=f:field(TextValue,"B",translate("Black Domain List"))
t.rmempty=true
t.rows=8
t.description=translate("Black Domain List")
function t.cfgvalue()
	return fs.readfile(black) or ""
end

t=f:field(TextValue,"C",translate("Netflix Domain List"))
t.rmempty=true
t.rows=8
t.description=translate("Netflix Domain List")
function t.cfgvalue()
	return fs.readfile(netflix) or ""
end

t=f:field(TextValue,"D",translate("Oversea domain"))
t.rmempty=true
t.rows=8
t.description=translate("Oversea domain")
function t.cfgvalue()
	return fs.readfile(oversea) or ""
end

t=f:field(TextValue,"E",translate("Preload domain(GFW Only)"))
t.rmempty=true
t.rows=8
t.description=translate("Preload domain(GFW Only)")
function t.cfgvalue()
	return fs.readfile(preload) or ""
end

function f.handle(self,state,data)
	if state==FORM_VALID then
		if data.A then
			fs.writefile(white,data.A:gsub("\r\n","\n"))
		else
			luci.sys.call("> /etc/bypass/white.list")
		end
		if data.B then
			fs.writefile(black,data.B:gsub("\r\n","\n"))
		else
			luci.sys.call("> /etc/bypass/black.list")
		end
		if data.C then
			fs.writefile(netflix,data.C:gsub("\r\n","\n"))
		else
			luci.sys.call("> /etc/bypass/netflix.list")
		end
		if data.D then
			fs.writefile(oversea,data.D:gsub("\r\n","\n"))
		else
			luci.sys.call("> /etc/bypass/oversea.list")
		end
		if data.E then
			fs.writefile(preload,data.E:gsub("\r\n","\n"))
		else
			luci.sys.call("> /etc/bypass/preload.list")
		end
		luci.sys.exec("/etc/init.d/bypass restart")
	end
	return true
end

return f

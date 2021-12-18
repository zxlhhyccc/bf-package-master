local e = require"nixio.fs"
local a = "/usr/bin/conf/nps.conf"
f = SimpleForm("custom",translate("Nps Server"),
translate("可在此页面修改NPS服务器的默认配置参数<br />修改提交后服务器自动重启，重启时间大概30秒~2分钟<br />旁路模式需要在主路由做8024和7777端口映射到服务器"))
t = f:field(TextValue,"conf")
t.rmempty = true
t.rows = 25
function t.cfgvalue()
return e.readfile(a)or""
end
function f.handle(i,o,t)
if o == FORM_VALID then
if t.conf then
e.writefile(a,t.conf:gsub("\r\n","\n"))
luci.sys.call("/etc/init.d/Nps restart")
end
end
return true
end
return f

local fs = require "nixio.fs"
local sys = require "luci.sys"

m = Map("AdGuardHome", translate("<font color=\"green\">AdGuard Home高级配置</font>"), translate("<font color=\"red\">此处直接修改AdGuardHome.yaml文件，错误的修改会导致程序崩溃，如若崩溃请执行重置。</font>"))
s = m:section(TypedSection, "AdGuardHome")
s.anonymous=true

o = s:option(TextValue, "/usr/bin/AdGuardHome.yaml")
o.rows = 20
o.wrap = "off"
function o.cfgvalue(self, section)
    return fs.readfile("/usr/bin/AdGuardHome.yaml") or ""
end

function o.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/AdGuardHome.yaml", value)
        if (luci.sys.call("cmp -s /tmp/AdGuardHome.yaml /usr/bin/AdGuardHome.yaml") == 1) then
            fs.writefile("/usr/bin/AdGuardHome.yaml", value)
            luci.sys.call("/etc/init.d/AdGuard-Home restart >/dev/null")
        end
        fs.remove("/tmp/AdGuardHome.yaml")
    end
end

return m


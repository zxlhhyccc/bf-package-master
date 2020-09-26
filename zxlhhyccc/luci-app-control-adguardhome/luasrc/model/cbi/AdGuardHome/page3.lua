--mod by wulishui 20191107

local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

local m,s
m = Map("AdGuardHome", translate("<font style='color:green'>AdGuard Home重置</font>"))
m.description = translate("")

s = m:section(TypedSection, "AdGuardHome")
s.anonymous=true
s.addremove=false
enabled = s:option(Flag, "reset", translate("<font style='color:brown'>重置</font>"))
enabled.default = 0
enabled.rmempty = true
enabled.description = translate("<font style='color:brown'>可以重置AdGuard Home到初始化状态。</font>")

Confirm = s:option(Flag, "Confirm_reset", translate("<font style='color:red'>确认重置</font>"))
Confirm.default = 0
Confirm.rmempty = true
Confirm.description = translate("<font style='color:red'>警告！！！点选并应用后即重置AdGuard Home、所有配置以及日志都将丢失！！！</font>")
Confirm:depends("reset", 1)

return m


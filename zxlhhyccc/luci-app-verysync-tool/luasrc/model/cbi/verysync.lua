--[[
LuCI - Lua Configuration Interface

Copyright 2011 flyzjhz <flyzjhz@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

local SYS  = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local lanipaddr = uci:get("network", "lan", "ipaddr") or "192.168.1.1"
--- Retrieves the output of the "get_verysync_port" command.
-- @return	String containing the current get_verysync_port

local verysyncport = uci:get("verysync", "setting", "port") or "88"

local verysync_bin="/usr/bin/verysync"
	verysync_version=SYS.exec(verysync_bin.." --version  2>/dev/null | grep -m 1 -E 'v[0-9]+[.][0-9.]+' -o|grep v|tr -d v")

m = Map("verysync")
m.title = translate("Verysync Synchronization Tool")
m.description = translate("微力同步是一款跨平台分布式同步软件。")

m:section(SimpleSection).template  = "verysync/verysync_status"

s = m:section(TypedSection, "verysync")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enable",  translate("启用微力"))
enable.default = false
enable.optional = false
enable.rmempty = false

e=s:option(DummyValue,"verysync_version",translate("verysync 版本"))
e.rawhtml  = true
e.value =verysync_version

e=s:option(DummyValue,"verysyncweb",translate("Open the verysync Webui"))
e.rawhtml  = true
e.value ="<strong><a target=\"_blank\" href='http://"..lanipaddr..":"..verysyncport.."'><font style=\"color:green\">打开verysync软件控制界面</font></a></strong>"

delay = s:option(Value, "delay", translate("启动前等待时间(秒)"))
delay:value("0", translate("0"))
delay:value("5", translate("5"))
delay:value("10", translate("10"))
delay:value("20", translate("20"))
delay:value("40", translate("40"))
delay:value("60", translate("60"))
delay:value("80", translate("80"))
delay:value("100", translate("100"))
delay:value("120", translate("120"))

port = s:option(Value, "port", translate("Port"), translate("可自定义微力管理界面端口号"))
port:value("8886", "8886")
port:value("8889", "8889")

port.default = "88"
port.optional = true
port.rmempty = true

dl_mod = s:option(Value, "dl_mod", translate("执行文件存放路径"))
dl_mod.default = '/usr/bin/verysync'

device = s:option(Value, "device", translate("配置文件存放路径"))
device.default = '/etc/verysync'

o = s:option(Button, "网站")
o.title = translate("官方网站")
o.inputtitle = translate("打开网站")
o.inputstyle = "apply"
o.write = function()
	luci.http.redirect("http://verysync.com/")
end

o = s:option(Button, "论坛")
o.title = translate("微力论坛")
o.inputtitle = translate("打开论坛")
o.inputstyle = "apply"
o.write = function()
	luci.http.redirect("https://forum.verysync.com/")
end


return m



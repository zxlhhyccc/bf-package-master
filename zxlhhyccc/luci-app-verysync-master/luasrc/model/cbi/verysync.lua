--[[
LuCI - Lua Configuration Interface

Copyright 2011 flyzjhz <flyzjhz@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

]]--

local wa = require "luci.tools.webadmin"
local fs = require "nixio.fs"
local util = require "nixio.util"
local SYS  = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local lanipaddr = uci:get("network", "lan", "ipaddr") or "192.168.1.1"
--- Retrieves the output of the "get_verysync_port" command.
-- @return	String containing the current get_verysync_port

local verysyncport = uci:get("verysync", "setting", "port") or "88"

local running=(luci.sys.call("pidof verysync > /dev/null") == 0)

local verysync_version=translate("Unknown")
local verysync_bin="/usr/bin/verysync"
if not fs.access(verysync_bin)  then
	-- verysync_version=translate("Not exist")
	verysync_version="<font color=\"Navy\"><b>在设置提交的时候会自动下载程序,请定时刷新该页面检查结果。</b></font>"
else
	verysync_version=SYS.exec("cat /etc/verysync_version")
	if not verysync_version or verysync_version == "" then
		verysync_version = translate("Unknown")
	end
end

if running then
	m = Map("verysync", translate("verysync"), "<b><font color=\"green\">微力同步正在运行!</font></b>")
else
	m = Map("verysync", translate("verysync"), "<b><font color=\"red\">" .. translate("微力同步未启动") .. "</font></b>")
end

s = m:section(NamedSection, "setting", "verysync", translate("Settings"), translate("(微力同步是一款跨平台分布式同步软件。"))
s.anonymous = true
s.addremove = false

enable = s:option(Flag, "enable",  "启用微力")
enable.default = false
enable.optional = false
enable.rmempty = false

function enable.write(self, section, value)
	if value == "0" then
		os.execute("/etc/init.d/verysync disable")
		os.execute("/etc/init.d/verysync stop")
	else
		os.execute("/etc/init.d/verysync enable")
	end
	Flag.write(self, section, value)
end

e=s:option(DummyValue,"verysync_version",translate("verysync 版本"))
e.rawhtml  = true
e.value =verysync_version

e=s:option(DummyValue,"verysync_author",translate("官方网站"))
e.rawhtml  = true
e.value ="<strong><a target=\"_blank\" href='http://verysync.com/'><font color=\"red\">http://verysync.com/</font></a></strong>"

e=s:option(DummyValue,"luci_author",translate("微力论坛"))
e.rawhtml  = true
e.value ="<strong><a target=\"_blank\" href='https://forum.verysync.com/'><font color=\"red\">https://forum.verysync.com/</font></a></strong>"

-- e=s:option(DummyValue,"verysync_url",translate("执行文件手动下载"))
-- e.rawhtml  = true
-- e.value ="<strong><a target=\"_blank\" href='https://github.com/verysync/releases/releases'><font color=\"red\">https://github.com/verysync/releases/releases</font></a></strong>"

delay = s:option(Value, "delay", translate("启动前等待时间(秒)"))
delay:value("5", translate("5"))
delay:value("10", translate("10"))
delay:value("20", translate("20"))
delay:value("40", translate("40"))
delay:value("60", translate("60"))
delay:value("80", translate("80"))
delay:value("100", translate("100"))
delay:value("120", translate("120"))

local devices = {}
util.consume((fs.glob("/mnt/sd??*")), devices)
device = s:option(Value, "device", translate("挂载点"), translate("微力同步软件目录所在的“挂载点”。"))
for i, dev in ipairs(devices) do
	device:value(dev)
end
if nixio.fs.access("/etc/config/verysync") then
	device.titleref = luci.dispatcher.build_url("admin", "system", "fstab")
end

port = s:option(Value, "port", translate("Port"), translate("自定义微力管理界面端口号"))
port:value("8886", "8886")
port:value("8889", "8889")

port.default = "88"
port.optional = true
port.rmempty = true


if not nixio.fs.access("/usr/bin/verysync") then
downloadfile=1		
end

if downloadfile==1 then

dl_mod = s:option(Value, "dl_mod", translate("下载选择"), translate("选择下载执行文件的方式，也可以使用自定义下载方式；还可以手动下载文件，再在“系统”“文件传输”上传至/var/filetransfer/，软件启动时将自动检测并自动运行！！"))
-- dl_mod:value("git", "GIT下载")
-- dl_mod:value("verysync", "默认下载")
dl_mod:value("verysync", "微力官方服务器")
dl_mod:value("custom", "自定义下载")

-- dl_mod.default = "git"
dl_mod.default = "verysync"
dl_mod.optional = true
dl_mod.rmempty = true

-- e = s:option(Button, "get_verysync_version", translate("获取版本"), translate("从官方获取可下载软件的版本，获取版本后约30秒须刷新一次界面。"))
-- e.inputtitle = translate("获取版本")
-- e.inputstyle = "apply"

-- function e.write(self, section)
-- 	os.execute("/usr/bin/verysync_ver")
-- 	self.inputtitle = translate("获取版本")
-- end
-- e:depends("dl_mod", "git")

-- get_verysync_ver = s:option(Value, "get_verysync_ver", translate("获取版本命令"), ("在此可编辑获取github上版本信息的命令。"))
-- get_verysync_ver.template = "cbi/tvalue"
-- get_verysync_ver.rows = 2
-- get_verysync_ver.wrap = "off"
-- get_verysync_ver:depends("dl_mod", "git")

-- if not nixio.fs.access("/usr/bin/verysync_ver") then
-- 	os.execute("touch /usr/bin/verysync_ver && chmod 0755 /usr/bin/verysync_ver")
-- end

-- function get_verysync_ver.cfgvalue(self, section)
-- 	return fs.readfile("/usr/bin/verysync_ver") or ""
-- end

-- function get_verysync_ver.write(self, section, value)
-- 	if value then
-- 		value = value:gsub("\r\n?", "\n")
-- 		fs.writefile("/tmp/verysync_ver", value)
-- 		if (luci.sys.call("cmp -s /tmp/verysync_ver /usr/bin/verysync_ver") == 1) then
-- 			fs.writefile("/usr/bin/verysync_ver", value)
-- 		end
-- 		fs.remove("/tmp/verysync_ver")
-- 	end
-- end

e = s:option(Button, "get_verysync_version_d", translate("获取版本"), translate("从官网获取可下载软件的版本，获取版本后约30秒可须刷新一次界面。"))
e.inputtitle = translate("获取版本")
e.inputstyle = "apply"

function e.write(self, section)
	-- os.execute("curl -k -s http://releases-cdn.verysync.com/releases/ |grep -E \"..*href..*v\" |sed 's/^..*>v//g'|awk -F '/' '{print $1}' |sort -r >/tmp/log/verysync_version_d &")
	os.execute("curl -k -s http://www.verysync.com/shell/latest|grep v|tr -d v>/tmp/log/verysync_version_d &")
	self.inputtitle = translate("获取版本")
end
e:depends("dl_mod", "verysync")

-- e = s:option(ListValue, "version_g","下载执行文件版本", "git下载时，需要先执行上面的获取版本，并刷新页面。")
-- for i_1 in io.popen("cat /tmp/log/verysync_version", "r"):lines() do
--     e:value(i_1)
-- end
-- e:depends("dl_mod", "git")

e = s:option(ListValue, "version_d","下载执行文件版本")
for i_1 in io.popen("cat /tmp/log/verysync_version_d", "r"):lines() do
    e:value(i_1)
end
e:depends("dl_mod", "verysync")

end

e = s:option(Value, "c_url", "自定义执行文件下载网址", "网址中以http或者https开始，包含文件名的完整网址！！")
e:depends("dl_mod", "custom")

e = s:option(DummyValue, "manual", "手动上传文件", "点箭头可跳转至手动上传文件的界面，上传完文件后，在此页面启动软件，将会自动安装。")
if nixio.fs.access("/etc/config/verysync") then
	e.titleref = luci.dispatcher.build_url("admin", "system", "file_transfer", "filetransfer")
end
e:depends("dl_mod", "custom")

e=s:option(DummyValue,"verysyncweb",translate("Open the verysync Webui"))
e.rawhtml  = true
e.value ="<strong><a target=\"_blank\" href='http://"..lanipaddr..":"..verysyncport.."'><font color=\"red\">打开verysync软件控制界面</font></a></strong>"

s:option(Flag, "more", translate("More Options"))

e = s:option(Button, "del_sync", translate("重置微力"), translate("Sometims the download files is incorrect, you can delete them.<br/> <font color=\"Red\"><strong>Delete files only when multiple startup failures. When the synchronization is successful, it must not be deleted!!</strong></font>"))
e.inputtitle = translate("重置微力")
e.inputstyle = "apply"

function e.write(self, section)
	os.execute("/usr/bin/del_verysync.sh &")
	self.inputtitle = translate("del_sync")
end
e:depends("more", "1")

return m


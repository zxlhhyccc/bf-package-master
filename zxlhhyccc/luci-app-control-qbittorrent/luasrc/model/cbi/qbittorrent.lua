-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.
--mod by wulishui 20191115FKU!

require("luci.model.ipkg")
local fs  = require "nixio.fs"
require("nixio.fs")

local uci = require "luci.model.uci".cursor()
local vport = uci:get_first("qbittorrent", "setting", "port") or 8080

local m, s

local running=(luci.sys.call("pidof qbittorrent-nox > /dev/null") == 0)

local button = ""
local state_msg = ""

if running then
        state_msg = "<b><font color=\"green\">" .. translate("～正在运行～") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("qbittorrent在睡觉觉zZZ") .. "</font></b>"
end

if running  then
	button = "<br/><br/>---<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("打开管理界面").." \" onclick=\"window.open('http://'+window.location.hostname+':"..vport.."')\"/>---"
end

m = Map("qbittorrent", translate("qbittorrent"))
m.description = translate("<font color=\"green\">一个基于Qt的BT/PT下载软件。详情见：<a href=\"https://www.qbittorrent.org/\" target=\"_blank\">官方网站</a></font>".. button
        .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />")
--<br/><font color=\"red\">chrome需要在弹出页面地址栏按一次回车</font>
s = m:section(TypedSection, "setting", translate(""))
s.anonymous = true

enabled = s:option(Flag, "enabled", translate("Enable"),translate("<b><font color=\"red\">进行以下配置会导致进程重启，勿在存在下载任务时配置。</font></b>"))

port = s:option(Value, "port", translate("WEB管理端口"),translate("可随意设置为其它无冲突端口，对程序运行无影响。"))
s.placeholder=8080
s.default = 8080
s.datatype="port"
s.rmempty = true

profile_dir = s:option(Value,"profile_dir",translate("配置文件目录"),translate("设在有永久储存权限的路径可避免更新固件后丢失配置。"))
s.placeholder="/mnt/sda1"
s.default="/mnt/sda1"
s.datatype="profile_dir"
s.rmempty=true

downloadpath = s:option(Value,"downloadpath",translate("下载文件目录"),translate("下载的文件会存放在此。"))
s.placeholder="/mnt/sda1/download"
s.default="/mnt/sda1/download"
s.datatype="downloadpath"
s.rmempty=true

GlobalDLLimit = s:option(Value, "GlobalDLLimit", translate("全局下载限速<br/>(KB)"),translate("为总限速，长期生效。0 为不限制，n 则以webui中配置为准。"))
s.placeholder=0
s.default = 0
s.rmempty = false

GlobalUPLimit = s:option(Value, "GlobalUPLimit", translate("全局上传限速<br/>(KB)"),translate("为总限速，长期生效。0 为不限制，n 则以webui中配置为准。"))
s.placeholder=0
s.default = 0
s.rmempty = false

GlobalDLLimitAlt = s:option(Value, "GlobalDLLimitAlt", translate("备用下载限速<br/>(KB)"),translate("可在webui临时切换或计划限速使用。0 为不限制，n 则同上。"))
s.placeholder=0
s.default = 0
s.rmempty = false

GlobalUPLimitAlt = s:option(Value, "GlobalUPLimitAlt", translate("备用上传限速<br/>(KB)"),translate("可在webui临时切换或计划限速使用。0 为不限制，n 则同上。"))
s.placeholder=0
s.default = 0
s.rmempty = false

GlobalMaxSeedingMinutes = s:option(Value, "GlobalMaxSeedingMinutes", translate("做种时限<br/>(min)"),translate("到达时间即暂停做种。<b><font color=\"red\">-1</font></b> 为不限制，n 则同上。"))
s.placeholder=0
s.default = 0
s.rmempty = false

return m


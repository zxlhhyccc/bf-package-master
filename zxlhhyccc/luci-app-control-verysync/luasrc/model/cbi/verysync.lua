-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.
--mod by wulishui 20191111

require("luci.model.ipkg")
local fs  = require "nixio.fs"
require("nixio.fs")

local uci = require "luci.model.uci".cursor()
local vport = uci:get_first("verysync", "setting", "port") or 8886

local m, s

local running=(luci.sys.call("pidof verysync > /dev/null") == 0)

local button = ""
local state_msg = ""

if running then
        state_msg = "<b><font color=\"green\">" .. translate("～正在运行～") .. "</font></b>"
else
        state_msg = "<b><font color=\"red\">" .. translate("verysync在睡觉觉zZZ") .. "</font></b>"
end

if running  then
	button = "<br/><br/>---<input class=\"cbi-button cbi-button-apply\" type=\"submit\" value=\" "..translate("打开管理界面").." \" onclick=\"window.open('http://'+window.location.hostname+':"..vport.."')\"/>---"
end

m = Map("verysync", translate("An Efficient Data Transfer Tool"))
m.description = translate("<font color=\"green\">一个简单易用的多平台文件同步软件，最大优势是不同于其他产品的惊人的传输速度、智能P2P技术会将文件分割成若干份仅KB的数据进行同步，而文件都会进行AES加密处理。</font><br /><br />使用向导：verysync无严格意义的服务器端与客户端，双方地位对等都可以作为远程储存端或（和）主动同步端。<br />1.远程储存端：启用后进入web管理界面，新建一个空的标准文件夹作为备份文件存放目录，复制弹出的读写权限共享链接备用。详情见：<a href=\"http://www.verysync.com/manual/\" target=\"_blank\">使用手册</a><br />2.主动同步端：到<a href=\"http://www.verysync.com/download.html\" target=\"_blank\">官方网站</a>下载对应版本到本地机运行，在弹出的web管理界面新建目录，按“输入密钥或链接”，粘贴上一步复制的网址后按提示指向要同步的目录。<br />3.仅只读共享：新建文件夹，指向想要共享的目录（不能是文件）、复制弹出的只读权限共享网址发送给对方。对方执行第2步操作即可取出文件。".. button
        .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg .. "<br />")

s = m:section(TypedSection, "setting", translate(""))
s.anonymous = true

s:option(Flag, "enabled", translate("Enable"))

s:option(Value, "port", translate("port"),translate("为web管理端口，可随意设定为无冲突的端口，对程序运行无影响。")).default = 8886
s.rmempty = true

s:option(Value,"home",translate("Home directory"),translate("配置文件会存放在此，设在有永久储存权限的路径可避免更新固件后丢失配置。")).default="/mnt/sda1/verysync"
s.rmempty=true

return m


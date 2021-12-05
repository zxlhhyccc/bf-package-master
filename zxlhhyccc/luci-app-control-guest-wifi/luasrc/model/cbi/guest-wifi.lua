local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
require("luci.tools.webadmin")
local net = require "luci.model.network".init()
local ifaces = sys.net:devices()
local button = ""
local state_msg = ""
local m,s,n

local wlan=(luci.sys.call("[ `ls /sys/class/net|grep -c 'wlan' 2>/dev/null` -gt 0 ] ") == 0)
local running=(luci.sys.call("[ -f /etc/config/guestwifi/guest_del ] >/dev/null") == 0)
local limited=(luci.sys.call("[ `tc -s qdisc show dev $(grep 'DEVICE' /tmp/log/guest_wifi_limit 2>/dev/null| awk -F ' ' '{print $3}') 2>/dev/null|grep -c 'default' 2>/dev/null` -gt 0 ] >/dev/null") == 0)
--local iface=(luci.sys.call("uci get network.$(grep 'interface_name' /etc/config/guestwifi/guest_del 2>/dev/null|awk -F ' ' '{print $3}').auto >/dev/null 2>&1") == 0)
local disabled=(luci.sys.call("uci get wireless.guest.disabled >/dev/null 2>&1") == 0)
local sltradio=(luci.sys.call("[ $(uci get guest-wifi.@guest-wifi[0].device 2>/dev/null) -eq 0 ] 2>/dev/null") == 0)
local ul=(luci.sys.call("[ $(uci get guest-wifi.@guest-wifi[0].wifi_up 2>/dev/null) -eq 0 ] 2>/dev/null") == 0)
local dl=(luci.sys.call("[ $(uci get guest-wifi.@guest-wifi[0].wifi_dn 2>/dev/null) -eq 0 ] 2>/dev/null") == 0)

if limited then
        state_msg3 = "<b style=\"color:green\">" .. translate(" 限速✓") .. "</b>"
else
        state_msg3 = "<b style=\"color:red\">" .. translate(" 未限速") .. "</b>"
end

if ul and dl then
        state_msg3 = "<b style=\"color:red\">" .. translate(" 不限速") .. "</b>"
end

if wlan then
if disabled then
        state_msg2 = "<b style=\"color:red\">" .. translate(" 访客Wifi未打开") .. "</b>"
else
        state_msg2 = "<b style=\"color:green\">" .. translate(" 访客Wifi✓") .. "</b>"
end
end

if sltradio then
        state_msg2 = "<b style=\"color:red\">" .. translate(" 不使用访客Wifi") .. "</b>"
end

if not wlan then
        state_msg2 = "<b style=\"color:red\">" .. translate(" 无Wifi设备") .. "</b>"
end

if running then
        state_msg = "<b style=\"color:green\">" .. translate(" 配置✓") .. "</b>"
else
        state_msg = "<b style=\"color:red\">" .. translate(" 配置未创建") .. "</b>"
        state_msg2 = "<b style=\"color:gray\">" .. translate(" ") .. "</b>"
        state_msg3 = "<b style=\"color:gray\">" .. translate(" ") .. "</b>"
end

m = Map("guest-wifi", translate("Guest-network"))
m.description = translate("访客网络使用与主网络不同的网段以及防火墙隔离技术来保障主网络的安全不被访客干扰，并可对其进行限速以避免占用过多网络资源。如已选“有线设备”，软件可以在没有无线设备情况下运行。").. button .. "<br/><br/>" .. translate("运行状态：") .. state_msg .. translate(" -|-") .. state_msg3 .. translate(" -|-") .. state_msg2 .. ""

if running then
s = m:section(TypedSection, "guest-wifi", translate(""), translate("<b><font color=\"black\">开关</font></b> 可以关闭或开启而无须改变配置，“访客WIFI”关闭后重启也为关闭状态；“访客限速”则为临时关闭，到设定的“关闭时限”时会自动开启。如已选用“有线设备”，该功能需到“接口”处开关。"))
s.anonymous = true 
s.addremove = false

--
if wlan and not sltradio then
if disabled then
enable_wifi = s:option(Button, "enable_wifi", translate("打开访客Wifi信号"))
function enable_wifi.write()
    sys.exec("guest_wifi_on")
    sys.exec("sleep 6")
    luci.http.redirect(luci.dispatcher.build_url("admin", "network", "guest-wifi"))
end
else
enable_wifi = s:option(Button, "enable_wifi", translate("关闭访客Wifi信号"))
function enable_wifi.write()
    sys.exec("guest_wifi_off")
    sys.exec("sleep 1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "network", "guest-wifi"))
end
end
end

--
if not ul or not dl then
if limited then
enable_limit = s:option(Button, "enable_limit", translate("临时关闭访客限速"))
function enable_limit.write()
    sys.exec("/usr/bin/guest_wifi_crond 2>/dev/null")
    sys.exec("sleep 1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "network", "guest-wifi"))
end
else
enable_limit = s:option(Button, "enable_limit", translate("打开访客网络限速"))
function enable_limit.write()
    sys.exec("guest_wifi_limit &")
    sys.exec("sleep 1")
    luci.http.redirect(luci.dispatcher.build_url("admin", "network", "guest-wifi"))
end
end
end
--
end

s = m:section(TypedSection, "guest-wifi", translate(""), translate("<b><font style=\"color:black\">设置</font></b> 下方配置除限速项目（<font style=\"color:brown\">棕色部分</font>）外，如需修改并且投入使用，则需要先勾选“创建配置”、再修改、然后按“保存并应用”，等候10秒钟后重新打开页面即可看到运行结果。"))
s.anonymous = true 
s.addremove = false

s:tab("basic", translate("Basic Options"))

enable = s:taboption("basic",Flag, "create", translate("创建配置"), translate("必须创建配置才可使用访客网络。后续可在“无线”中修改与无线有关的配置。"))
enable.default = false
enable.optional = false
enable.rmempty = false


wifi_up = s:taboption("basic",Value, "wifi_up", translate("总上传限速<br/>（MB/s）"), translate("<font style=\"color:brown\">填0关闭。无须选择“创建配置”修改即可生效。速率如无单位默认为“MB/s”；带K、M、G，为“B/s”；带k、m、g为“b/s”。</font>"))
wifi_up.default = "0"
wifi_up.rmempty = true

wifi_dn = s:taboption("basic",Value, "wifi_dn", translate("总下载限速<br/>（MB/s）"), translate("<font style=\"color:brown\">填0关闭。无须选择“创建配置”修改即可生效。速率如无单位默认为“MB/s”；带K、M、G，为“B/s”；带k、m、g为“b/s”。</font>"))
wifi_dn.default = "0"
wifi_dn.rmempty = true

ip_up = s:taboption("basic",Value, "ip_up", translate("单用户上传<br/>（MB/s）"), translate("<font style=\"color:brown\">填0关闭。无须选择“创建配置”修改即可生效。速率如无单位默认为“MB/s”；带K、M、G，为“B/s”；带k、m、g为“b/s”。</font>"))
ip_up.default = "0.1"
ip_up.rmempty = true

ip_dn = s:taboption("basic",Value, "ip_dn", translate("单用户下载<br/>（MB/s）"), translate("<font style=\"color:brown\">填0关闭。无须选择“创建配置”修改即可生效。速率如无单位默认为“MB/s”；带K、M、G，为“B/s”；带k、m、g为“b/s”。</font>"))
ip_dn.default = "0.1"
ip_dn.rmempty = true

offtimer = s:taboption("basic",Value, "offtimer", translate("临时关闭"), translate("<font style=\"color:brown\">为“临时关闭Wifi限速”的临时时限，更改后须先按“保存并应用”再按“临时关闭访客Wifi限速”方可生效。</font>"))
offtimer:value("10", translate("10分钟"))
offtimer:value("30", translate("30分钟"))
offtimer:value("60", translate("1小时"))
offtimer:value("120", translate("2小时"))
offtimer:value("240", translate("4小时"))
offtimer:value("360", translate("6小时"))
offtimer:value("720", translate("12小时"))
offtimer:value("1440", translate("24小时"))
offtimer.default = "30"

if wlan then
device = s:taboption("basic",ListValue, "device", translate("无线设备"), translate("承载访客wifi的无线网卡，选none则仅配置有线访客网络，无Wifi，或之后将某个无线网卡（<font style=\"color:red\">需先在br-lan解除原有桥接</font>）桥接到br-guest接口使用。"))
device:value("radio0", "radio0")
device:value("radio1", "radio1")
device:value("radio2", "radio2")
device:value("0", "-none-")
device.default = "radio0"

wifi_name = s:taboption("basic",Value, "wifi_name", translate("Wifi名称"), translate("Define the name of guest wifi"))
wifi_name:depends("device","radio0")
wifi_name:depends("device","radio1")
wifi_name:depends("device","radio2")
wifi_name.default = "Guest-IOU"
wifi_name.rmempty = true

encryption = s:taboption("basic",ListValue, "encryption", translate("Wifi加密"), translate("Define encryption of guest wifi"))
encryption:depends("device","radio0")
encryption:depends("device","radio1")
encryption:depends("device","radio2")
encryption:value("psk", "WPA-PSK")
encryption:value("psk2", "WPA2-PSK")
encryption:value("none", "No Encryption")
encryption.default = "psk2"
encryption.widget = "select"

passwd = s:taboption("basic",Value, "passwd", translate("Wifi密码"), translate("Define the password of guest wifi"))
passwd:depends("device","radio0")
passwd:depends("device","radio1")
passwd:depends("device","radio2")
passwd.password = true
passwd.default = "12345678"

isolate = s:taboption("basic",ListValue, "isolate", translate("用户隔离"), translate("开启或关闭与其它LAN网段、用户与用户之间的隔离"))
isolate:depends("device","radio0")
isolate:depends("device","radio1")
isolate:depends("device","radio2")
isolate:value("1", translate("YES"))
isolate:value("0", translate("NO"))
isolate.default = "1"
end

s:tab("advance", translate("Advanced Options"))

e = s:taboption("advance",DynamicList, "ifname", translate("网卡设备"), translate("将<font style=\"color:red\">空闲未用</font>（否则须<font style=\"color:red\">先将其解除桥接</font>）的网卡（有线或无线）如eth0、wlan1桥接到访客网络可实现对连接其的用户进行隔离，等同于在接口br-guest的“物理设置”中桥接。"))
for _, iface in ipairs(ifaces) do
if not ( iface:match("_ifb$")) then
	if ( iface:match("^eth*") or iface:match("^usb*") or iface:match("^wlan*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		e:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
end
--e.default = "br-lan"
e.rmempty = true

interface_name = s:taboption("advance",Value, "interface_name", translate("接口名称"), translate("承载访客Wifi的接口名称，后续如修改更多接口桥接等等可在“接口”中修改相关配置。"))
interface_name.default = "guest"
interface_name.rmempty = true

interface_ip = s:taboption("advance",Value, "interface_ip", translate("IPv4地址"), translate("Define IP address for guest wifi"))
interface_ip.datatype = "ip4addr"
interface_ip.default ="192.254.245.1"

device = s:taboption("advance",ListValue, "forcedhcp", translate("强制DHCP"), translate("如不强制DHCP分配IP，曾经连接过主网络的用户在DHCP租期内将不能再获取访客IP，比如某些原因需要切换主客网络时候。"))
device:value("0", "自动")
device:value("1", "强制")
device.default = "0"

start = s:taboption("advance",Value, "start", translate("DHCP开始数"), translate("Lowest leased address as offset from the network address"))
start.default = "50"
start.rmempty = true

limit = s:taboption("advance",Value, "limit", translate("DHCP客户数"), translate("Maximum number of leased addresses"))
limit.default = "200"
limit.rmempty = true

leasetime = s:taboption("advance",Value, "leasetime", translate("DHCP租期"), translate("纯数字为分钟，数字加h为小时，数字加d为天。最短2分钟。"))
leasetime.default = "1h"
leasetime.rmempty = true

create = s:taboption("advance",Flag, "delete", translate("<font color=\"red\">删除配置"), translate("勾选并应用后访客无线即时停止使用并且所有访客网络配置会被清除。</font>"))
create.default = false
create.optional = false
create.rmempty = false

return m





local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"
local ifaces = sys.net:devices()
local a,e,t,m,s,n
local button = ""
local state_msg3 = ""
local state_msg4 = ""
local aaa=(luci.sys.call("[ `iptables -L FORWARD 2>/dev/null|grep -c '^userrestriction' 2>/dev/null` -gt 0 ] > /dev/null") == 0)
local bbb=(luci.sys.call("[ `iptables -L userrestriction 2>/dev/null|grep -c 'userrestriction' 2>/dev/null` -gt 1 ] > /dev/null") == 0)
local ccc=(luci.sys.call("pidof userrestriction.sh >/dev/null 2>&1") == 0)
local ddd=(luci.sys.call("[ $(uci get userrestriction.@basic[0].enabled 2>/dev/null) == 0 ] 2>/dev/null") == 0)
local lucimode=(luci.sys.call("[ $(uci get userrestriction.@basic[0].lucimode 2>/dev/null) == 1 ] 2>/dev/null") == 0)
local ruleswt=(luci.sys.call("[ $(iptables -L userrestriction 2>/dev/null|grep -c 'userrestriction') == $(cat /etc/config/userrestriction 2>/dev/null|grep -c 'option enable .1.'|awk '{print$1+1}') ] 2>/dev/null") == 0)
local pausemode=(luci.sys.call("[ -s /tmp/log/time_stop_userrestriction ]") == 0)
local pausestoptime = (luci.sys.exec("cat /tmp/log/time_stop_userrestriction 2>/dev/null"))

if aaa then
        state_msg1 = "<b><font color=\"green\">" .. translate("主链✓") .. "</font></b>"
else
        state_msg1 = "<b><font color=\"red\">" .. translate("主链×") .. "</font></b>"
end

if bbb then
        state_msg2 = "<b><font color=\"green\">" .. translate(" -|- ") .. translate("子链✓") .. "</font></b>"
else
        state_msg2 = "<b><font color=\"red\">" .. translate(" -|- ") .. translate("子链×") .. "</font></b>"
end

if ccc then
        state_msg3 = "<b><font color=\"green\">" .. translate(" -|- ") .. translate("进程✓") .. "</font></b>"
else
        state_msg3 = "<b><font color=\"red\">" .. translate(" -|- ") .. translate("进程×") .. "</font></b>"
end

if not ruleswt then
        state_msg4 = "<b><font color=\"red\">" .. translate(" -|- ") .. translate("：实际生成的iptables规则数量不符，可能某些条件设置有误，需要检查！") .. "</font></b>"
end

if pausemode then
	 state_msg2 = ""
        state_msg3 = "<b><font color=\"red\">" .. translate(" -|- ") .. translate("临时放行至：".. pausestoptime .."") .. "</font></b>"
        state_msg4 = ""
end

if ddd then
state_msg1 = ""
state_msg2 = ""
state_msg3 = ""
state_msg4 = "<b><font color=\"gray\">" .. translate("功能未启用") .. "</font></b>"
end

a = Map("userrestriction", translate("用户控制/时间控制/接口控制/MAC黑白名单/IP黑白名单/URL关键字过滤"), translate("可控制MAC/IP/接口联网、过滤包含关键字的数据包的工具。注：白名单模式定时仅定时时间内可联网。在某条规则“URL/关键字”处填入!可改其为与当前限制模式相反的模式(即白名单中可存在黑名单，反之亦然)。").. button .. "<br/><br/>" .. translate("运行状态").. " : "  .. state_msg1 .. state_msg2  .. state_msg3 .. state_msg4 .. "<br />")
e = a:section(TypedSection, "basic", translate(""))
e.anonymous = true

e:tab("general", translate("<b><font color=\"black\">功能开关</font></b>"))
e:tab("Advance", translate("<b><font color=\"black\">高级功能</font></b>"))

t = e:taboption("general", Flag, "enabled", translate("功能开关") , translate(""))
t.rmempty = false

t = e:taboption("general", ListValue, "limit_type", translate("限制模式"), translate("*一旦某条规则URL/关键字填入!则该条规则工作在与此处设定相反的模式；非!的其它内容则都是工作在黑名单模式。"))
t.default = "blacklist"
t:value("whitelist", translate("白名单---（仅允许名单内用户联网）"))
t:value("blacklist", translate("黑名单---（仅禁止名单内用户联网）"))
t.rmempty = false

if pausemode then
pausemodeon = e:taboption("general", Button, "pausemodeon", translate("取消放行"), translate("<b><font style='color:red'>".. pausestoptime .." 超时</font></b>，到时会自动取消放行，亦可点击上方按钮立即取消放行。临时放行不会因重启软件、系统而终止，除非超时或手动取消。"))
pausemodeon.inputstyle = "reset"
function pausemodeon.write()
   sys.exec("/usr/bin/userrestrictionfunction stop")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end
else
pausemodeoff = e:taboption("general", Button, "pausemodeoff", translate("临时放行"), translate("点击可临时放行除URL黑名单外其它名单，临时停止时长可在“高级功能”里配置。"))
pausemodeoff.inputstyle = "save"
function pausemodeoff.write()
   sys.exec("/usr/bin/userrestrictionfunction start")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end
end

if lucimode then
simple = e:taboption("Advance", Button, "simple", translate("简单界面"), translate("点击切换到简单界面"))
function simple.write()
   sys.exec("uci set userrestriction.@basic[0].lucimode='0'")
   sys.exec("uci commit userrestriction")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end
else
complex = e:taboption("Advance", Button, "complex", translate("复杂界面"), translate("点击切换到复杂界面---可控制源接口、源IP/IP段如192.168.18.10-20"))
function complex.write()
   sys.exec("uci set userrestriction.@basic[0].lucimode='1'")
   sys.exec("uci commit userrestriction")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end
end

addlist = e:taboption("Advance", Button, "addlist", translate("导入MAC名单"), translate("导入下方“名单文件”中的MAC名单，建议先执行“清除名单”后导入。</font></br><font color=\"red\">*按下后如右上角出现“未保存的配置”需点击进入后按“恢复”按钮。</font>"))
function addlist.write()
    sys.exec("/usr/bin/userrestrictionfunction add")
   luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end

listfile = e:taboption("Advance", Value, "listfile", translate("MAC名单文件"))
listfile.description = translate("*更改文件路径后需要按“保存并应用”后再按“导入名单”才会生效。")
listfile:value("/etc/cowbbonding/list.cfg", translate("1.“静态绑定”里的MAC名单"))
listfile:value("/etc/swobl/macwhitelist", translate("2.“名单控制”里的MAC白名单"))
listfile:value("/etc/swobl/macblacklist", translate("3.“名单控制”里的MAC黑名单"))
listfile:value("/etc/webrlistfile", translate("4.“打开”编辑框填入批量MAC名单"))
listfile.default = '/etc/cowbbonding/list.cfg'

conf = e:taboption("Advance", Value, "webrlistfile", nil, translate(""))
conf:depends("listfile", '/etc/webrlistfile')
conf.template = "cbi/tvalue"
conf.rows = 24
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/webrlistfile") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/etc/webrlistfile", value)
        if (luci.sys.call("cmp -s /tmp/etc/webrlistfile /etc/webrlistfile") == 1) then
            fs.writefile("/etc/webrlistfile", value)
        end
        fs.remove("/tmp/etc/webrlistfile")
    end
end

clrlist = e:taboption("Advance", Button, "clrlist", translate("清除MAC名单"), translate("<font color=\"red\">此操作会先备份已设的所有MAC、IP名单至/etc/userrestriction后清除。<br>*注意：如果一条规则既有IP又有URL/关键字，执行清除后会新增重复。</font>"))
clrlist.inputstyle = "reset"
function clrlist.write()
    sys.exec("/usr/bin/userrestrictionfunction clr")
    luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end

misoperation = e:taboption("Advance", Button, "misoperation", translate("误操作恢复"), translate("<font color=\"green\">意外进行以上两项操作后可恢复原来的名单设置，但仅能恢复最后一次。</font></br><font color=\"red\">*按下后如右上角出现“未保存的配置”需点击进入后按“恢复”按钮。</font>"))
misoperation.inputstyle = "apply"
function misoperation.write()
    sys.exec("/usr/bin/userrestrictionfunction restore")
    luci.http.redirect(luci.dispatcher.build_url("admin", "control", "userrestriction"))
end

--[[
algos = e:taboption("Advance", ListValue, "algos", translate("URL过滤力度"), translate("仅URL/关键字过滤使用此设置。强效过滤效果更好，但耗用资源更多。"))
algos:value("bm", "一般过滤")
algos:value("kmp", "强效过滤")
algos.default = "kmp"
]]--
---

pausetime = e:taboption("Advance", Value, "pausetime", translate("临时放行时长"), translate("单位“分钟”，修改后按“保存并应用”再使用“临时放行”才会生效。"))
pausetime.default = "60"

e = a:section(TypedSection, "macbind", translate(""), translate("<b><font color=\"black\">规则说明：</font> </b>条件可单独或组合使用。如仅选接口（时间、星期可选）则仅控制经该接口接入的用户；如仅选MAC（时间、星期可选）则为MAC限制；如仅选IP（时间、星期可选）则为IP限制；MAC、IP都选（时间、星期可选）则必须符合该MAC又符合该IP的客户端才受限制；如其它都没选而仅改变了时间、星期则所有主机都受时间控制。IP可以是单IP或IP掩码如192.168.18.1/24或IP段如192.168.18.10-20。"))
e.template = "cbi/tblsection"
e.anonymous = true
e.addremove = true

t = e:option(Flag, "enable", translate("开启"))
t.rmempty = false
t.default = "1"

if lucimode then
t = e:option(Value, "interface", translate("接口<font color=\"green\">(可留空)</font>&nbsp;"), translate(""))
for _, iface in ipairs(ifaces) do
if not (iface:match("_ifb$") or iface:match("^ifb*")) then
	if ( iface:match("^eth*") or iface:match("^wlan*") or iface:match("^usb*") or iface:match("^br*")) then
		local nets = net:get_interface(iface)
		nets = nets and nets:get_networks() or {}
		for k, v in pairs(nets) do
			nets[k] = nets[k].sid
		end
		nets = table.concat(nets, ",")
		t:value(iface, ((#nets > 0) and "%s (%s)" % {iface, nets} or iface))
	end
end
end
t.rmempty = true
end

t = e:option(Value, "macaddr", translate("&nbsp;&nbsp;MAC地址<font color=\"green\">(已选IP或URL则可留空)</font>&nbsp;&nbsp;"))
t.rmempty = true
sys.net.mac_hints(function(e, a) t:value(e, "%s (%s)" % {e, a}) end)

if lucimode then
ip = e:option(Value, "IP", translate("&nbsp;&nbsp;IP/IP段<font color=\"green\">(已选MAC或URL则可留空)</font>&nbsp;&nbsp;"))
ip.rmempty = true
ipc.neighbors({family = 4, dev = "br-lan"}, function(n)
	if n.mac and n.dest then
	 ip:value(n.dest:string(), "%s (%s)" %{ n.dest:string(), n.mac })
	end
end)
end

    function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "时间格式必须为 HH:MM 或者留空"
        end
    end

    t = e:option(Value, "start_time", translate("起控时间"))
        t.default = '00:00'
        t.rmempty = true
        t.validate = validate_time 
        t.size = 5
    t = e:option(Value, "stop_time", translate("停控时间")) 
        t.default = '00:00'
        t.rmempty = true
        t.validate = validate_time
        t.size = 5

    t = e:option(MultiValue, "daysofweek", translate("星期<font color=\"green\">(至少选一天，某天不选则该天不进行控制)</font>"))
        t.optional = false
        t.rmempty = false
        t.default = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
        t:value("Monday", translate("一"))
        t:value("Tuesday", translate("二"))
        t:value("Wednesday", translate("三"))
        t:value("Thursday", translate("四"))
        t:value("Friday", translate("五"))
        t:value("Saturday", translate("六"))
        t:value("Sunday", translate("日"))

comment = e:option(Value, "keyword", translate("URL/关键字<font color=\"green\">(可空)</font>"))

return a




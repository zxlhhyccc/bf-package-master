module("luci.controller.npc",package.seeall)

local sys = require "luci.sys"

function index()
	if not nixio.fs.access("/etc/config/npc") then
		return
	end

	local page = entry({"admin", "services", "npc"}, alias("admin", "services", "npc", "setting"), _("Nps Client"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-npc-client" }

	entry({"admin", "services", "npc", "setting"}, cbi("npc/nps_client"), _("Base Setting"),10).leaf = true
	entry({"admin", "services", "npc", "log"}, template("npc/npc_log"), _("Logs"),30).leaf = true
	--entry({"admin", "services", "npc", "log"}, cbi("npc/log")).leaf = true
	--entry({"admin", "services", "npc", "get_log"}, call("get_log")).leaf = true
	--entry({"admin", "services", "npc", "clear_log"}, call("clear_log")).leaf = true
	entry({"admin","services","npc","status"}, call("act_status")).leaf = true
	entry({"admin","services","npc","logdata"}, call("act_log")).leaf = true
end

function act_status()
	local e = {}
	e.running=luci.sys.call("pgrep npc > /dev/null") == 0
	e.bin_version = luci.sys.exec("npc --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function act_log()
	local log_data={}
	log_data.syslog=sys.exec("logread | grep 'npc' | sed -e 's/daemon\\S* //' -e 's/([^ ]*\\]//' -e 's/[^ ]* //'")
	luci.http.prepare_content("application/json")
	luci.http.write_json(log_data)
end
--[[
function get_log()
	sys.exec("logread | grep 'npc' | sed -e 's/daemon\\S* //' -e 's/([^ ]*\\]//' -e 's/[^ ]* //' > $(uci -q get npc.@npc[0].log_file) 2>/dev/null")
	luci.http.write(sys.exec("[ -f $(uci -q get npc.@npc[0].log_file) ] && cat $(uci -q get npc.@npc[0].log_file)"))
end
	
function clear_log()
	sys.call("cat /dev/null > $(uci -q get npc.@npc[0].log_file)")
end
--]]

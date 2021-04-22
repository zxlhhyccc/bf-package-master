module("luci.controller.vlmcsd",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/vlmcsd") then
		return
	end

	local page = entry({"admin","services", "vlmcsd"}, alias("admin", "services", "vlmcsd", "base"), _("KMS Server"))
	page.order = 100
	page.dependent = true
	page.acl_depends = { "luci-app-control-vlmcsd" }
	entry({"admin", "services", "vlmcsd", "base"}, cbi("vlmcsd/base"), _("Base Setting"), 10).leaf = true
	entry({"admin", "services", "vlmcsd", "config"}, form("vlmcsd/config"), _("Config File"), 20).leaf = true
	entry({"admin", "services", "vlmcsd", "log"}, form("vlmcsd/log"), _("Log"), 30).leaf = true
	entry({"admin", "services", "vlmcsd", "run"}, call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep /usr/bin/vlmcsd >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

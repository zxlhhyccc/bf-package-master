module("luci.controller.nps-server",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/nps-server") then
		return
	end

	local page = entry({"admin", "services", "nps-server"}, alias("admin", "services", "nps-server", "setting"), _("Nps Server Setting"), 60)
	page.dependent = true
	page.acl_depends = { "luci-app-nps-server-compat" }

	entry({"admin", "services", "nps-server", "setting"}, cbi("nps-server/nps_server"), _("Setting"), 10).leaf = true
	entry({"admin", "services", "nps-server", "nps-server"}, template("nps-server/nps_server"), _("Nps Server Setting"), 20).leaf = true
	entry({"admin","services", "nps-server","status"}, call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep nps > /dev/null") == 0
	e.bin_version = luci.sys.exec("nps --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

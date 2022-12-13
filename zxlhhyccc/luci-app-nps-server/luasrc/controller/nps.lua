module("luci.controller.nps",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/nps") then
		return
	end

	local page = entry({"admin", "services", "nps"}, alias("admin", "services", "nps", "setting"), _("Nps Server Setting"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-nps-server" }

	entry({"admin", "services", "nps", "setting"}, cbi("nps/nps_server")).leaf = true
	entry({"admin","services","nps","status"}, call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep nps > /dev/null") == 0
	e.bin_version = luci.sys.exec("nps --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end


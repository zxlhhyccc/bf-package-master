module("luci.controller.nps",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/nps") then
		return
	end
	
	local e
	e=entry({"admin","services","nps"},cbi("nps"),_("Nps Server Setting"),100)
	e.i18n = "nps"
	e.dependent = true
	entry({"admin","services","nps","status"},call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep nps > /dev/null") == 0
	e.bin_version = luci.sys.exec("nps --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

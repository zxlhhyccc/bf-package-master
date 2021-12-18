module("luci.controller.npc",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/npc")then
		return
	end

	local e
	e=entry({"admin","services","npc"},cbi("npc"),_("Nps Client"))
	e.i18n="npc"
	e.dependent=true
	entry({"admin","services","npc","status"},call("act_status")).leaf=true
end

function act_status()
	local e = {}
	e.running=luci.sys.call("pgrep npc > /dev/null") == 0
	e.bin_version = luci.sys.exec("npc --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

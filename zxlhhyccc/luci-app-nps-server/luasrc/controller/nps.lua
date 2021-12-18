module("luci.controller.nps",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/nps")then
		return
	end

	entry({"admin","services"},firstchild(),"SERVICES",100).dependent=false
	entry({"admin","services","nps"},firstchild(),_("Nps Server")).dependent=false
	entry({"admin","services","nps","basic"},cbi("nps/nps"),_("Basic Setting"),1)
	entry({"admin","services","nps","conf"},form("nps/conf"),_("Nps Conf"),2)
	entry({"admin","services","nps","status"},call("act_status"))
end


function act_status()
	local e={}
	e.running=luci.sys.call("pgrep nps >/dev/null") == 0
	e.bin_version = luci.sys.exec("nps --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end


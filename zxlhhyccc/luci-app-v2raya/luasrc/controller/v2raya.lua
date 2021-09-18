module("luci.controller.v2raya",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/v2raya") then
		return
	end

	entry({"admin", "services", "v2raya"}, cbi("v2raya"), _("v2rayA"),99).dependent = true
	entry({"admin", "services", "v2raya", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("ps | grep v2raya | grep -v grep >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

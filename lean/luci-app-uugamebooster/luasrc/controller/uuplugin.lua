module("luci.controller.uuplugin",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/uuplugin") then return end

	local page = entry({"admin", "services", "uuplugin"}, cbi("uuplugin/uuplugin"), ("UU GameAcc"))
	page.order = 99
	page.dependent = true
	page.acl_depends = { "luci-app-uugamebooster" }
	entry({"admin", "services", "uuplugin", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep -f uuplugin >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

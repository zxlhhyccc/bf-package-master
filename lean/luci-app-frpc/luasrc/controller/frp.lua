module("luci.controller.frp", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/frp") then
		return
	end

	local page = entry({"admin", "services", "frp"},cbi("frp/frp"), _("Frp Setting"))
	page.order = 100
	page.dependent = true
	page.acl_depends = { "luci-app-frpc" }
	entry({"admin", "services", "frp", "config"}, cbi("frp/config")).leaf = true
	entry({"admin", "services", "frp", "status"}, call("status")).leaf = true
end

function status()
	local e={}
	e.running=luci.sys.call("pidof frpc > /dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

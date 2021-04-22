
module("luci.controller.adbyby", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/adbyby") then
		return
	end
	
	local page = entry({"admin", "services", "adbyby"}, cbi("adbyby"), _("ADBYBY Plus +"))
	page.order = 11
	page.dependent = true
	page.acl_depends = { "luci-app-adbyby-plus-ram_edition" }
	entry({"admin", "services", "adbyby", "status"},call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep adbyby >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

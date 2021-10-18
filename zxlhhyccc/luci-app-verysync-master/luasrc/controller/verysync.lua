module("luci.controller.verysync", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/verysync") then
		return
	end

	local page
	
	entry({"admin", "nas"}, firstchild(), _("NAS"), 30).dependent=false                                            

	page = entry({"admin", "nas", "verysync"}, cbi("verysync"), _("微力同步"), 80)
	page.i18n = "verysync"
	page.dependent = true
end

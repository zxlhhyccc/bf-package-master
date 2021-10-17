module("luci.controller.verysync", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/verysync") then
		return
	end

	local page
	
	entry({"admin", "service"}, firstchild(), _("Services"), 30).dependent=false                                            

	page = entry({"admin", "services", "verysync"}, cbi("verysync"), _("微力同步"), 80)
	page.i18n = "verysync"
	page.dependent = true
end

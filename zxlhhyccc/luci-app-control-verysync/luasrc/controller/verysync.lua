module("luci.controller.verysync", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/verysync") then
		return
	end
	
	local page = entry({"admin", "nas", "verysync"}, cbi("verysync"), _("Verysync"), 10)
	page.dependent = true
	page.acl_depends = { "luci-app-control-verysync" }
end


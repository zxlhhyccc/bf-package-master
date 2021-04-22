module("luci.controller.guest-wifi", package.seeall)

function index()
	require("luci.i18n")
	if not nixio.fs.access("/etc/config/guest-wifi") then
		return
	end
	
	local page = entry({"admin", "network", "guest-wifi"}, cbi("guest-wifi"), translate("Guest-network"), 20)
	page.i18n = "guest-wifi"
	page.dependent = true
	page.acl_depends = { "luci-app-control-guest-wifi" }
	
end

module("luci.controller.Wirelessaccesscontrol", package.seeall)

local fs = require "nixio.fs"

function index()
	if not nixio.fs.access("/etc/config/wireless") then return end
	if not nixio.fs.access("/etc/config/wirelessaccesscontrol") then return end

	entry({"admin", "network", "Wirelessaccesscontrol"}, cbi("wirelessaccesscontrol"), _("Wireless access control"), 18).dependent = true
end


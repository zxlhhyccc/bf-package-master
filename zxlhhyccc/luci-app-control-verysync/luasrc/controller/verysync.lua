module("luci.controller.verysync", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/verysync") then
		return
	end
	
	entry({"admin", "nas", "verysync"}, cbi("verysync"), _("Verysync"), 10).dependent = true
end


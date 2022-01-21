-- This is a free software, use it under GNU General Public License v3.0.
-- Created By immortalwrt
-- https://github.com/immortalwrt

module("luci.controller.ssocksd", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/ssocksd") then
		return
	end
	local page

	page = entry({"admin", "vpn", "ssocksd"}, cbi("ssocksd"), _("sSocksd Server"), 100)
	page.i18n = "ssocksd"
	page.dependent = true
	entry({"admin", "vpn", "ssocksd", "status"},call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep ssocksd > /dev/null") == 0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

module("luci.controller.weburl", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/weburl") then
		return
	end

	entry({"admin", "control"}, firstchild(), "Control", 50).dependent = false
	local page = entry({"admin", "control", "weburl"}, cbi("weburl"), _("网址过滤"), 12)
	page.dependent = true
	page.acl_depends = { "luci-app-control-weburl" }
end


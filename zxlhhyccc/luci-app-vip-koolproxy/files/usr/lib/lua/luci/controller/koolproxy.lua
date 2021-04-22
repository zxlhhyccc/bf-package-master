module("luci.controller.koolproxy",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/koolproxy")then
		return
	end

	local page = entry({"admin", "services", "koolproxy"}, cbi("koolproxy/global"), _("广告过滤 VIP"), 1)
	page.dependent = true
	page.acl_depends = { "luci-app-vip-koolproxy" }
	entry({"admin", "services","koolproxy", "rss_rule"}, cbi("koolproxy/rss_rule"), nil).leaf = true
end

module("luci.controller.AdGuardHome",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/AdGuardHome")then
		return
	end

	local page = entry({"admin", "services", "AdGuardHome"},alias("admin", "services", "AdGuardHome","page1"),_("AdGuard Home"),2)
	page.dependent = true
	page.acl_depends = { "luci-app-control-adguardhome" }
	entry({"admin", "services", "AdGuardHome","page1"}, cbi("AdGuardHome/page1"),_("设置"),10).leaf = true
	entry({"admin", "services", "AdGuardHome","page4"}, cbi("AdGuardHome/page4"),_("高级"),20).leaf = true
	entry({"admin", "services", "AdGuardHome","page2"}, cbi("AdGuardHome/page2"),_("帮助"),40).leaf = true
	entry({"admin", "services", "AdGuardHome","page3"}, cbi("AdGuardHome/page3"),_("重置"),30).leaf = true
end 


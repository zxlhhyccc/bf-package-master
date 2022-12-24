module("luci.controller.baidupcs-web", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/baidupcs-web") then
		return
	end

	local page = entry({"admin", "nas", "baidupcs-web"}, alias("admin",  "nas", "baidupcs-web", "baidupcs-web"), _("BaiduPCS Web"), 300)
	page.dependent = true
	page.acl_depends = { "luci-app-baidupcs-web-compat" }

	entry({"admin", "nas", "baidupcs-web", "baidupcs-web"}, cbi("baidupcs-web/baidupcs-web")).leaf = true
	entry({"admin", "nas", "baidupcs-web", "status"}, call("act_status")).leaf = true
end

function act_status()
	local e={}
	e.running=luci.sys.call("pgrep baidupcs-web >/dev/null")==0
	-- e.port=luci.sys.exec("uci get baidupcs-web.config.port")
	e.bin_version = luci.sys.exec("baidupcs-web --version  2>/dev/null | grep -m 1 -E '[0-9]+[.][0-9.]+' -o")
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end


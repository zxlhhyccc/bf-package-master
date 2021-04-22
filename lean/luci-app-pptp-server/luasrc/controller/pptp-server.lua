
module("luci.controller.pptp-server", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/pptpd") then
		return
	end
	
	entry({"admin", "vpn"}, firstchild(), "VPN", 45).dependent = false
	local page = entry({"admin", "vpn", "pptp-server"}, cbi("pptp-server/pptp-server"), _("PPTP VPN Server"), 80).dependent=false
	page.order = 80
	page.dependent = false
	page.acl_depends = { "luci-app-pptp-server" }
	entry({"admin", "vpn", "pptp-server", "status"}, call("act_status")).leaf = true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep pptpd >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end

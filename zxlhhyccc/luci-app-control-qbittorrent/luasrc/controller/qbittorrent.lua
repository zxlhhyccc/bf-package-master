module("luci.controller.qbittorrent",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/qbittorrent") then
		return
	end

	entry({"admin", "nas"}, firstchild(), "NAS", 46).dependent = false
        entry({"admin","nas","qbittorrent"},cbi("qbittorrent"),_("qbittorrent"))
end

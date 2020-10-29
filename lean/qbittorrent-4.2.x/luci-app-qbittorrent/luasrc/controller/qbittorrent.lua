-- Licensed to the public under the Apache License 2.0.

module("luci.controller.qbittorrent",package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qbittorrent") then
		return
	end

	entry({"admin", "services", "qbittorrent"}, view("qbittorrent/qbittorrent"), _("qBittorrent")).acl_depends = { "luci-app-qbittorrent" }
end

module("luci.controller.turboacc", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/turboacc") then
		return
	end
	local page
	page = entry({"admin", "network", "turboacc"}, cbi("turboacc"), _("Turbo ACC Center"), 101)
	page.i18n = "turboacc"
	page.dependent = true
	page.acl_depends = { "luci-app-turboacc" }
	
	entry({"admin", "network", "turboacc", "status"}, call("action_status"))
	entry({"admin", "network", "turboacc", "check_adguardhome"}, call("check_adguardhome"))
end

local function fastpath_status()
	return luci.sys.call("/etc/init.d/turboacc check_status fastpath >/dev/null") == 0
end

local function bbr_status()
	return luci.sys.call("/etc/init.d/turboacc check_status bbr") == 0
end

local function fullconenat_status()
	return luci.sys.call("/etc/init.d/turboacc check_status fullconenat") == 0
end

local function dnscaching_status()
	return luci.sys.call("/etc/init.d/turboacc check_status dns") == 0
end

local function adguardhome_status()
	return luci.sys.call("/etc/init.d/turboacc check_status adguardhome") == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		fastpath_state = fastpath_status(),
		fullconenat_state = fullconenat_status(),
		bbr_state = bbr_status(),
		dnscaching_state = dnscaching_status(),
		adguardhome_state = adguardhome_status()
	})
end

-- 在 turboacc.lua 中添加一个接口
function check_adguardhome()
    local result = nixio.fs.access("/usr/bin/AdGuardHome") -- 检查二进制文件是否存在
    luci.http.prepare_content("application/json")
    luci.http.write_json({ exists = result }) -- 返回检查结果
end

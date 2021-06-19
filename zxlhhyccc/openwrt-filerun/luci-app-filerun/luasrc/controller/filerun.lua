-- Copyright 2018-2020 Garypang <garyp@qq.com>
module("luci.controller.filerun", package.seeall)

local http = require "luci.http"
local uci=require"luci.model.uci".cursor()
function index()
    if not nixio.fs.access("/etc/config/filerun") then return end
    entry({"admin", "nas"}, firstchild(), _("NAS") , 45).dependent = false
    entry({"admin", "nas", "filerun"}, cbi("filerun"), _("FileRun"), 1)
    entry({"admin", "nas", "filerun", "status"}, call("get_pid")).leaf = true
    entry( {"admin", "nas", "filerun", "startstop"}, post("startstop") ).leaf = true
end

function get_pid(from_lua)
	local php_stat = luci.sys.call("pgrep php-fpm >/dev/null")==0
    local nginx_stat = luci.sys.call("pgrep nginx >/dev/null")==0
	local sql_stat = luci.sys.call("pgrep mysqld >/dev/null")==0
	local status = {
		php_stat = php_stat,
		nginx_stat = nginx_stat,
		sql_stat = sql_stat,
		kodport=uci:get("filerun","main","port"),
		kodomain=uci:get("filerun","main","kodomain")
	}
	if from_lua then
		return status
	else
		luci.http.prepare_content("application/json")
		luci.http.write_json(status)	
	end
end

-- called by XHR.get from detail_startstop.htm
function startstop()
	local pid = get_pid(true)
	if pid then
		luci.sys.call("/etc/init.d/php7-fpm stop")
		luci.sys.call("/etc/init.d/mysqld stop")
	end
	luci.http.write(tostring(pid))	-- HTTP needs string not number
end

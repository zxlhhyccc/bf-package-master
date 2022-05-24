module("luci.controller.npsvip",package.seeall)
function index()
if not nixio.fs.access("/etc/config/npsvip")then
return
end
local e
e=entry({"admin","services","npsvip"},cbi("npsvip"),_("小蝴蝶内网穿透"),100)
e.dependent=true
entry({"admin","services","npsvip","status"},call("status")).leaf=true
end
function status()
local e={}
e.running=luci.sys.call("pgrep npsvip > /dev/null")==0
luci.http.prepare_content("application/json")
luci.http.write_json(e)
end

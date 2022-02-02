module("luci.controller.timecontrol", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/timecontrol") then return end

    entry({"admin", "control"}, firstchild(), "Control", 60).dependent = false
    entry({"admin", "control", "timecontrol"}, cbi("timecontrol"), _("时段控制"), 13).dependent =
        true
end


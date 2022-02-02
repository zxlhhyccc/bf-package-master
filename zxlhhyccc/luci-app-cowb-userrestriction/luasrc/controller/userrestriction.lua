module("luci.controller.userrestriction", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/userrestriction") then return end

    entry({"admin", "control"}, firstchild(), "Control", 60).dependent = false
    entry({"admin", "control", "userrestriction"}, cbi("userrestriction"), _("用户控制"), 3).dependent = true
 end


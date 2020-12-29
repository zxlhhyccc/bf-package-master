local d = require "luci.dispatcher"
local appname = "bypass"

m = Map(appname)

-- [[ App Settings ]]--
s = m:section(TypedSection, "global", translate("App Update"),
              "<font color='red'>" ..
                  translate("Please confirm that your firmware supports FPU.") ..
                  "</font>")
s.anonymous = true
s:append(Template(appname .. "/xray_version"))
s:append(Template(appname .. "/v2ray_version"))
s:append(Template(appname .. "/trojan_go_version"))
s:append(Template(appname .. "/kcptun_version"))

return m

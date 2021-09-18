
m = Map("v2raya")
m.title = translate("v2rayA")
m.description = translate("简易的 v2rayA 开关")
m:section(SimpleSection).template = "v2raya/v2raya_status"

s = m:section(TypedSection,"v2raya")
s.anonymous = true

o = s:option(Flag,"enabled")
o.title = translate("启用")
o.description = translate("启用后，浏览器输入: 后台IP+:2017，例如:192.168.1.1:2017")
o.default = 0
o.rmempty = false

return m

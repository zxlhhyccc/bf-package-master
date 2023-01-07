m = Map("npsvip")
m.title = translate("<p style='margin-top:0.5em;'><font style='background:#20B2AA;color:#FFF;padding:0.5em;border-radius:5px;'>小蝴蝶内网穿透</font></p>")
m.description = translate("<div style='line-height:2.4em;padding-top:1em;'><p>应用场景：访问局域网OA、ERP系统、搭建网站服务、远程控制、本地开发联调、搭建NAS私有云盘、远程办公,游戏联机。</p><p>仅提供维护测试使用，请勿用于任何不健康等用途！此插件为爱好制作，不承担任何责任。</p><p style='color:red\;'>小蝴蝶官网：<a href='https://www.npsvip.com/share.html?code=325' target=_blank>https://www.npsvip.com/</a></p><p>本插件由你好多多DIY技术网站 <a href='http://www.nihaodd.com' target=_blank>NiHaoDD.Com</a> 于2022年9月更新！</p></div>")

m:section(SimpleSection).template = "nihaodd/npsvip_status"

s = m:section(TypedSection,"npsvip")
s.addremove = false
s.anonymous = true

s:tab("basic",translate("基本设置"))
enable = s:taboption("basic",Flag,"enabled",translate("启用"),translate("成功启动后大约需要10s~30s生效。"))
enable.rmempty = false

restart = s:taboption("basic",Button,"restart",translate("重启服务"))
restart.inputstyle = "restart"
restart.write = function()
luci.sys.exec("/etc/init.d/npsvip restart")
luci.http.redirect(luci.dispatcher.build_url("admin","services","npsvip"))
end

tmpl = s:taboption("basic",Value,"_tmpl",translate("配置参数"),translate("注意：请保护好你的配置文件，如果发现异常，请及时修改端口号以及内网IP并且在客户端重新配置!"))
tmpl.template = "cbi/tvalue"
tmpl.rows = 15
function tmpl.cfgvalue(e,e)
return nixio.fs.readfile("/etc/nihaodd/npc/npsvip.conf")
end
function tmpl.write(t,t,e)
e = e:gsub("\r\n?","\n")
nixio.fs.writefile("/etc/nihaodd/npc/npsvip.conf",e)
end

return m

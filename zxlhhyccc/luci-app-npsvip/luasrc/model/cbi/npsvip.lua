m=Map("npsvip")
m.title=translate("<font style='background:#20B2AA;color:#FFF;padding:0.5em;border-radius:5px;'>小蝴蝶内网穿透</font>")
m.description=translate("<div style='line-height:2.4em;padding-top:1em;'>小蝴蝶内网穿透提供3M免费测试通道，实名认证后可永久免费续期使用。<br />应用场景：访问局域网OA、ERP系统、搭建网站服务、远程控制、本地开发联调、搭建NAS私有云盘、远程办公,游戏联机。<br />仅提供维护测试使用，请勿用于任何不健康等用途！此插件为爱好制作，不承担任何责任，不提供任何技术支持。<p style='color:red\;'>小蝴蝶官网：<a href='https://www.npsvip.com/share.html?code=325' target=_blank>https://www.npsvip.com/</a><br />本插件安装以及使用教程 <a href='http://www.nihaodd.com/jiaocheng/333.php' target=_blank>http://www.nihaodd.com/jiaocheng/333.php</a><br />本插件由你好多多DIY技术网站 <a href='http://www.nihaodd.com' target=_blank>NiHaoDD.Com</a> 于2022年5月制作！</p></div>")

m:section(SimpleSection).template="ddwifi/npsvip_status"
s=m:section(TypedSection,"npsvip")
s.addremove=false
s.anonymous=true
s:tab("basic",translate("基本设置"))

enable=s:taboption("basic",Flag,"enabled",translate("启用"),translate("成功启动后大约需要10s~30s生效。"))
enable.rmempty=false
luci.sys.exec("/etc/init.d/npsvip start")

restart=s:taboption("basic",Button,"restart",translate("重启服务"))
restart.inputstyle="restart"
restart.write=function()
luci.sys.exec("/etc/init.d/npsvip restart")
luci.http.redirect(luci.dispatcher.build_url("admin","services","npsvip"))
end

tmpl=s:taboption("basic",Value,"_tmpl",translate("配置参数"),translate("注意：请保护好你的配置文件，如果发现异常，请及时修改端口号以及内网IP并且在客户端重新配置!"))
tmpl.template="cbi/tvalue"
tmpl.rows=15
function tmpl.cfgvalue(e,e)
return nixio.fs.readfile("/etc/conf/npsvip.conf")
end

function tmpl.write(t,t,e)
e=e:gsub("\r\n?","\n")
nixio.fs.writefile("/etc/conf/npsvip.conf",e)
end

return m

local t=require"luci.sys"
local e=t.net:devices()
m=Map("arpbind",translate("IP/MAC Binding"),
translatef("ARP is used to convert a network address (e.g. an IPv4 address) to a physical address such as a MAC address.Here you can add some static ARP binding rules."))
s=m:section(TypedSection,"arpbind",translate("Rules"))
s.template="cbi/tblsection"
s.anonymous=true
s.addremove=true
nolimit_ip=s:option(Value,"ipaddr",translate("IP Address"))
nolimit_ip.datatype="ipaddr"
nolimit_ip.optional=false
luci.ip.neighbors({family = 4}, function(neighbor)
if neighbor.reachable then
	nolimit_ip:value(neighbor.dest:string(), "%s (%s)" %{neighbor.dest:string(), neighbor.mac})
end
end)
nolimit_mac=s:option(Value,"macaddr",translate("MAC Address"))
nolimit_mac.datatype="macaddr"
nolimit_mac.optional=false
t.net.mac_hints(function(t,a)
nolimit_mac:value(t,"%s (%s)"%{t,a})                                                                                                                    
end)
a=s:option(ListValue,"ifname",translate("Interface"))
for t,e in ipairs(e)do
if e~="lo"then
a:value(e)
end
end
a.default="br-lan"
a.rmempty=false
return m

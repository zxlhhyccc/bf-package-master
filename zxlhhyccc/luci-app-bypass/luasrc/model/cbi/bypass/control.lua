local m,s,o

m=Map("bypass",translate("IP Access Control"))
s=m:section(TypedSection,"access_control")
s.anonymous=true

s:tab("wan_ac",translate("WAN IP AC"))

o=s:taboption("wan_ac",DynamicList,"wan_bp_ips",translate("WAN White List IP"))
o.datatype="ip4addr"

o=s:taboption("wan_ac",DynamicList,"wan_fw_ips",translate("WAN Force Proxy IP"))
o.datatype="ip4addr"

s:tab("lan_ac",translate("LAN IP AC"))

o=s:taboption("lan_ac",ListValue,"lan_ac_mode",translate("LAN Access Control"))
o:value("w",translate("Allow listed only"))
o:value("b",translate("Allow all except listed"))
o.rmempty=false

o=s:taboption("lan_ac",DynamicList,"lan_ac_ips",translate("LAN Host List"))
o.datatype="ipaddr"
luci.ip.neighbors({family=4},function(entry)
	if entry.reachable then
		o:value(entry.dest:string())
	end
end)
o:depends("lan_ac_mode","w")
o:depends("lan_ac_mode","b")

o=s:taboption("lan_ac",DynamicList,"lan_fp_ips",translate("LAN Force Proxy Host List"))
o.datatype="ipaddr"
luci.ip.neighbors({family=4},function(entry)
	if entry.reachable then
		o:value(entry.dest:string())
	end
end)

o=s:taboption("lan_ac",DynamicList,"lan_gm_ips",translate("Game Mode Host List"))
o.datatype="ipaddr"
luci.ip.neighbors({family=4},function(entry)
	if entry.reachable then
		o:value(entry.dest:string())
	end
end)

return m

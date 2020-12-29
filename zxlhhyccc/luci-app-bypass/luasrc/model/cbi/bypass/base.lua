local m,s,o
local ssr="bypass"

m=Map(ssr)
m:section(SimpleSection).template="bypass/status"

local server_table={}
luci.model.uci.cursor():foreach(ssr,"servers",function(s)
	if s.alias then
		server_table[s[".name"]]="[%s]:%s"%{string.upper(s.type),s.alias}
	elseif s.server and s.server_port then
		server_table[s[".name"]]="[%s]:%s:%s"%{string.upper(s.type),s.server,s.server_port}
	end
end)

local key_table={}
for key in pairs(server_table) do
	table.insert(key_table,key)
end
table.sort(key_table)

s = m:section(TypedSection, 'global')
s.anonymous=true

o=s:option(ListValue,"global_server",translate("Main Server"))
o:value("",translate("Disable"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o=s:option(ListValue,"udp_relay_server",translate("Game Mode UDP Server"))
o:value("",translate("Disable"))
o:value("same",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o=s:option(ListValue,"nf_server",translate("Netflix Server"))
o:value("",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end
o:depends("run_mode","gfw")
o:depends("run_mode","router")
o:depends("run_mode","all")

o=s:option(Flag,"nf_proxy",translate("External Proxy Mode"),
translate("Forward Netflix Proxy through Main Proxy"))
for _,key in pairs(key_table) do o:depends("nf_server",key) end

o=s:option(ListValue,"threads",translate("Multi Threads Option"))
o:value("0",translate("Auto Threads"))
o:value("1",translate("1 Thread"))
o:value("2",translate("2 Threads"))
o:value("4",translate("4 Threads"))
o:value("8",translate("8 Threads"))
o:value("16",translate("16 Threads"))
o:value("32",translate("32 Threads"))
o:value("64",translate("64 Threads"))
o:value("128",translate("128 Threads"))

o=s:option(ListValue,"run_mode",translate("Running Mode"))
o:value("router",translate("Smart Mode"))
o:value("gfw",translate("GFW List Mode"))
o:value("all",translate("Global Mode"))
o:value("oversea",translate("Oversea Mode"))

o=s:option(Flag,"gfw_mode",translate("Load GFW List"),
translate("If the domestic DNS does not hijack foreign domain name to domestic IP, No need to be enabled"))
o:depends("run_mode","router")

o=s:option(Flag,"pre_ip",translate("Preload IP"),
translate("Preload Google and Telegram IP segments (GFW mode only)"))
o:depends("run_mode","gfw")
o.default=1

o=s:option(Flag,"pre_domain",translate("Preload Domain"),
translate("Preload the domain name (GFW mode only,Solve the problem that the terminal fails to access the website in the list after Bypass restart or switch node)"))
o:depends("run_mode","gfw")
o.default=1

o=s:option(ListValue,"dports",translate("Proxy Ports"))
o:value("1",translate("All Ports"))
o:value("2",translate("Only Common Ports"))

o=s:option(ListValue,"dns_mode",translate("Foreign Resolve Dns Mode"))
o:value("0",translate("Use SmartDNS DoH query"))
o:value("1",translate("Use SmartDNS TCP query"))

o=s:option(Value,"dns",translate("Foreign DoH"),
translate("Custom DNS format is https://cloudflare-dns.com/dns-query or https://104.16.249.249/dns-query -http-host cloudflare-dns.com"))
o:value("","Cloudflare DoH")
o:value("google",""..translate("Google").." DoH")
o:value("quad9","Quad9 DoH")
o:value("opendns","OpenDNS DoH")
o:depends("dns_mode",0)

o=s:option(Value,"dns_nf",translate("Netflix DoH"),
translate("Do not use the same DNS server as the global server"))
o:value("",""..translate("Google").." DoH")
o:value("cloudflare","Cloudflare DoH")
o:value("quad9","Quad9 DoH")
o:value("opendns","OpenDNS DoH")
for _,key in pairs(key_table) do o:depends({nf_server=key,dns_mode=0}) end

o=s:option(Value,"tcp_dns",translate("Foreign DNS"),
translate("Custom DNS format is 1.1.1.1:53,1.0.0.1 ,Port optional"))
o:value("","1.1.1.1,1.0.0.1 (Cloudflare DNS)")
o:value("8.8.8.8,8.8.4.4","8.8.8.8,8.8.4.4 (Google DNS)")
o:value("9.9.9.9,149.112.112.112","9.9.9.9,149.112.112.112 (Quad9 DNS)")
o:value("208.67.222.222,208.67.220.220","208.67.222.222,208.67.220.220 (OpenDNS)")
o:depends("dns_mode",1)

o=s:option(Value,"tcp_dns_nf",translate("Netflix DNS"),
translate("Do not use the same DNS server as the global server"))
o:value("","8.8.8.8,8.8.4.4 (Google DNS)")
o:value("1.1.1.1,1.0.0.1","1.1.1.1,1.0.0.1 (Cloudflare DNS)")
o:value("9.9.9.9,149.112.112.112","9.9.9.9,149.112.112.112 (Quad9 DNS)")
o:value("208.67.222.222,208.67.220.220","208.67.222.222,208.67.220.220 (OpenDNS)")
for _,key in pairs(key_table) do o:depends({nf_server=key,dns_mode=1}) end

o=s:option(ListValue,"dns_mode_l",translate("Domestic Resolve Dns Mode"),
translate("If DoH resolution is not normal,use UDP mode and select ISP DNS"))
o:value("0",translate("Use SmartDNS DoH query"))
o:value("1",translate("Use SmartDNS UDP query"))

o=s:option(Value,"dns_l",translate("Domestic DoH"),
translate("Custom DNS format is https://dns.alidns.com/dns-query or https://223.5.5.5/dns-query"))
o:value("",""..translate("Ali").." DoH")
o:value("1","Dnspod DoH")
o:depends("dns_mode_l",0)

o=s:option(Flag,"isp_dns",translate("ISP DNS"),
translate("Use ISP DNS to resolve DoH domain"))
o:depends("dns_mode_l",0)

o=s:option(Value,"udp_dns",translate("Domestic DNS"),
translate("Custom DNS format is 223.5.5.5:53,223.6.6.6 ,Port optional"))
o:value("",translate("ISP DNS"))
o:value("223.5.5.5,223.6.6.6","223.5.5.5,223.6.6.6 ("..translate("Ali").." DNS)")
o:value("119.29.29.29,182.254.116.116","119.29.29.29,182.254.116.116 (Dnspod DNS)")
o:value("114.114.114.114,114.114.115.115","114.114.114.114,114.114.115.115 (114 DNS)")
o:depends("dns_mode_l",1)
m:section(SimpleSection).template = 'bypass/status_bottom'
return m

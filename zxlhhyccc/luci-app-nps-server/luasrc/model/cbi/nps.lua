m=Map("nps")
m.title=translate("Nps Server Setting")
m.description=translate("Nps is a fast reverse proxy to help you expose a local server behind a NAT or firewall to the internet.")

m:section(SimpleSection).template="nps/nps_status"

s=m:section(TypedSection,"nps")
s.addremove=false
s.anonymous=true

s:tab("basic",translate("Basic Setting"))
s:tab("web",translate("Web Setting"))
s:tab("proxy",translate("Proxy"))
s:tab("bridge",translate("Bridge"))
s:tab("key",translate("Auth Key"))

enable=s:taboption("basic",Flag,"enabled",translate("Enabled"))
enable.rmempty=false

log_level=s:taboption("basic",ListValue,"log_level",translate("Log Level"))
log_level:value(0,"Emergency")
log_level:value(1,"Alert")
log_level:value(2,"Critical")
log_level:value(3,"Error")
log_level:value(4,"Warning")
log_level:value(5,"Notice")
log_level:value(6,"Info")
log_level:value(7,"Debug")
log_level.default="3"

log_path=s:taboption("basic",Value,"log_path",translate("Log Path"))
log_path.datatype="string"
log_path.default="nps.log"
log_path.optional=false
log_path.rmempty=false

runmode=s:taboption("basic",ListValue,"runmode",translate("Boot mode"))
runmode.default="dev"
runmode:value("dev",translate("Dev"))
runmode:value("pro",translate("Pro"))

ip_limit=s:taboption("basic",ListValue,"ip_limit",translate("ip_limit"),translate("ip limit switch"))
ip_limit.default="true"
ip_limit:value("true",translate("True"))
ip_limit:value("false",translate("False"))


web_host=s:taboption("web",Value,"web_host",translate("Server"),translate("Server Domain/IP"))
web_host.default="x.y.com"
web_host.datatype="host"
web_host.optional=false
web_host.rmempty=false

web_ip=s:taboption("web",Value,"web_ip",translate("Web access address"))
web_ip.default="0.0.0.0"
web_ip.optional=false
web_ip.rmempty=false

web_username=s:taboption("web",Value,"web_username",translate("Web Username"))
web_username.datatype="string"
web_username.default="admin"
web_username.optional=false
web_username.rmempty=false

web_password=s:taboption("web",Value,"web_password",translate("Web Password"))
web_password.datatype="string"
web_password.default="123"
web_password.optional=false
web_password.rmempty=false

web_port=s:taboption("web",Value,"web_port",translate("Web Port"))
web_port.datatype="port"
web_port.default="8080"
web_port.optional=false
web_port.rmempty=false

http_proxy_ip=s:taboption("proxy",Value,"http_proxy_ip",translate("http_proxy_ip"))
http_proxy_ip.datatype="ipaddr"
http_proxy_ip.default="0.0.0.0"
http_proxy_ip.optional=true
http_proxy_ip.rmempty=true


http_proxy_port=s:taboption("proxy",Value,"http_proxy_port",translate("http_proxy_port"))
http_proxy_port.datatype="port"
http_proxy_port.default="62080"
http_proxy_port.optional=false
http_proxy_port.rmempty=false

https_proxy_port=s:taboption("proxy",Value,"https_proxy_port",translate("https_proxy_port"))
https_proxy_port.datatype="port"
https_proxy_port.default="62443"
https_proxy_port.optional=false
https_proxy_port.rmempty=false


bridge_ip=s:taboption("bridge",Value,"bridge_ip",translate("bridge_ip"))
bridge_ip.datatype="ipaddr"
bridge_ip.default="0.0.0.0"
bridge_ip.optional=false
bridge_ip.rmempty=false

bridge_port=s:taboption("bridge",Value,"bridge_port",translate("bridge_port"))
bridge_port.datatype="port"
bridge_port.default="8024"
bridge_port.optional=false
bridge_port.rmempty=false

public_vkey=s:taboption("key",Value,"public_vkey",translate("public_vkey"),translate("Public password, which clients can use to connect to the server"))
public_vkey.datatype="string"
public_vkey.default="123"
public_vkey.optional=false
public_vkey.rmempty=false

auth_key=s:taboption("key",Value,"auth_key",translate("auth_key"),translate("Web API unauthenticated IP address(the len of auth_crypt_key must be 16)"))
auth_key.datatype="string"
auth_key.default="test"
auth_key.optional=false
auth_key.rmempty=false

auth_crypt_key=s:taboption("key",Value,"auth_crypt_key",translate("auth_crypt_key"),translate("Web API unauthenticated IP address(the len of auth_crypt_key must be 16)"))
auth_crypt_key.datatype="string"
auth_crypt_key.default="1234567812345678"
auth_crypt_key.optional=false
auth_crypt_key.rmempty=false

return m



m = Map("filerun", translate("FileRun"), translate(
            "Self-Hosted File Sync and Sharing"))
m:append(Template("filerun/status"))

s = m:section(TypedSection, "filerun", translate("Global Settings"))
s.anonymous = true
s.addremove = false

o = s:option(Flag, "enable", translate("Enable Services"))
o.rmempty = false

o = s:option(Value, "port", translate("FileRun Port"))
o.datatype = "port"
o.placeholder = "8081"
o.rmempty = true

o = s:option(Value, "dbpasswd", translate("Database Password"))
o.default = "root"
o.password = true
o.rmempty = true

o = s:option(Value, "kodomain", translate("FileRun Bind Domain"))
o.placeholder = "filerun.xx.com"
o.rmempty = true

o = s:option(Value, "memory_limit", translate("Maximum memory usage"),
             translate(
                 "If your device has a lot of memory, you can increase it."))
o.placeholder = "200M"
o.rmempty = true

o = s:option(Value, "upload_max_filesize",
             translate("Maximum size for uploading files"))
o.placeholder = "200M"
o.rmempty = true

s:append(Template("filerun/version"))

return m

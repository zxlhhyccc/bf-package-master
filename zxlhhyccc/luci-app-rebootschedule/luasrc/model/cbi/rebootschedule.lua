require("luci.sys")
--mod by wulishui 20200908

m=Map("rebootschedule",translate("Reboot schedule"),translate("让计划任务更加易用的插件，可以使用-表示连续的时间范围，使用,表示不连续的多个时间点，使用*/表示循环执行。可以使用“添加”来添加多条计划任务命令。"))

s=m:section(TypedSection,"crontab","")
s.addremove=true
s.anonymous=true

enable=s:option(Flag,"enable",translate("enable"))
enable.rmempty = false
enable.default=0

month=s:option(Value,"month",translate("Month"), translate("数值范围1～12。1-5表示一年中1至5月份中每天都执行；1,5表示一年中仅1、5月份中每天执行；*表示全年每天都执行。"))
month.rmempty = false
month.default = '*'

day=s:option(Value,"day",translate("Day"), translate("数值范围1～31。1-5表示一个月中1至5号每天都执行；1,5表示一个月中仅1号、5号执行；*表示整个月中每天都执行。"))
day.rmempty = false
day.default = '*'

week=s:option(Value,"week",translate("Week Day"), translate("数值范围0～6。1-5表示一周中周一至五每天都执行；1,5表示表示一周中仅周一、五执行；*表示整星期中每天都执行。"))
week.rmempty = true
week:depends("day", '*')
week:value('*',translate("Everyday"))
week:value(0,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'

hour=s:option(Value,"hour",translate("Hour"),translate("数值范围0～23。1-5表示一天中1至5点钟每个钟都执行；1,5表示一天中仅1和5点钟执行；*表示每小时执行一次；*/5表示每隔5小时执行一次。"))
--hour.datatype = "range(0,23)"
hour.rmempty = false
hour.default = '5'

minute=s:option(Value,"minute",translate("Minute"),translate("数值范围0～59。1-5表示每小时中第1至5分钟每分钟执行一次；1,5表示每小时中仅第1和第5分钟各执行一次；*表示每分钟执行一次；*/5表示每隔5分钟执行一次。"))
--minute.datatype = "range(0,59)"
minute.rmempty = false
minute.default = '0'

command=s:option(Value,"command",translate("执行"),translate("多条命令用“ && ”连接；命令中不可以存在变量，如需要使用变量，请到计划任务去修改，并且把后面的#By rebootschedule删除。"))
command:value('reboot',translate("Reboot system"))
command:value('poweroff',translate("Power off"))
command:value('wifi down',translate("Wifi down"))
command:value('wifi up',translate("Wifi up"))
command:value('/etc/init.d/network restart',translate("Restart network"))
command:value('killall -q pppd && sleep 10 && pppd file /tmp/ppp/options.wan0',translate("Reconnect wan"))
command.default='reboot'


return m



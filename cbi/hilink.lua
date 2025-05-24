local fs = require("nixio.fs")
local sys = require("luci.sys")

map = Map("hilink", "Hilink Configuration", "Configure Hilink Modem settings.")
map.description = [[
<p>This tool helps to configure settings for various Huawei modem types including Orbit, E5372, E5577, E3372, and E5573.</p>
]]

section = map:section(NamedSection, "settings", "hilink", "Settings")
section.addremove = false
section.anonymous = true

option = section:option(Value, "router_ip", "Router IP")
option.datatype = "ipaddr"
option.default = "192.168.8.1"
option.placeholder = "Input IP Gateway Modem"

option = section:option(Value, "username", "Username")
option.default = "admin"
option.placeholder = "Input Username your Modem"

option = section:option(Value, "password", "Password")
option.password = true
option.default = "admin"
option.placeholder = "Input Password your Modem"

section = map:section(NamedSection, "settings", "hilink", "Duration")
section.addremove = false
section.anonymous = true

option = section:option(Value, "lan_off_duration", "Ping Duration (s)")
option.datatype = "uinteger"
option.default = 5
option.placeholder = "Enter Ping Duration in second"

-- Add a button for starting/stopping the service
service_btn = section:option(Button, "_service", "Control Services")
service_btn.inputstyle = "apply"

-- Add a custom title field for service control
status_title = section:option(DummyValue, "_status_title", ".", "")
status_title.rawhtml = true

-- Check service status via init.d
local function is_service_running()
    return sys.call("/etc/init.d/himon status >/dev/null") == 0
end

-- Update button text and title based on service status
local function update_status()
    if is_service_running() then
        service_btn.inputtitle = "Stop Service"
        service_btn.inputstyle = "remove"
        status_title.value = '<span style="color:green;">Service is Running</span>'
    else
        service_btn.inputtitle = "Start Service"
        service_btn.inputstyle = "apply"
        status_title.value = '<span style="color:red;">Service is Stopped</span>'
    end
end

-- Initial update
update_status()

-- Button action
function service_btn.write(self, section)
    if is_service_running() then
        sys.call("/etc/init.d/himon stop")
    else
        sys.call("/etc/init.d/himon enable")
        sys.call("/etc/init.d/himon start")
    end
    update_status()
end

return map

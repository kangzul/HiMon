local fs = require("nixio.fs")

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

-- Check if the service is running by checking /etc/rc.local
local function is_service_running()
    local rc_path = "/etc/rc.local"
    local script_line = "/usr/bin/himon -r"
    return fs.readfile(rc_path) and fs.readfile(rc_path):find(script_line, 1, true)
end

-- Update button text and title based on service status
local function update_status()
    if is_service_running() then
        service_btn.inputtitle = "Stop Service" -- Set the button label dynamically
        service_btn.inputstyle = "remove"
        status_title.value = '<span style="color:green;">Service is Running</span>'
    else
        service_btn.inputtitle = "Start Service" -- Set the button label dynamically
        service_btn.inputstyle = "apply"
        status_title.value = '<span style="color:red;">Service is Stopped</span>'
    end
end

-- Initial status update
update_status()

-- Function for toggling the service
function service_btn.write(self, section)
    local rc_path = "/etc/rc.local"
    local script_line = "/usr/bin/himon -r"

    if is_service_running() then
        -- Stop the service
        luci.sys.call("himon -s >/dev/null 2>&1")

        -- Remove the script from /etc/rc.local
        local rc_content = fs.readfile(rc_path)
        if rc_content then
            local new_content = rc_content:gsub(script_line:gsub("%-", "%%-") .. "\n?", "")
            fs.writefile(rc_path, new_content)
        end
    else
        -- Start the service
        luci.sys.call("himon -r >/dev/null 2>&1 &")

        -- Add the script to /etc/rc.local if not already present
        if not fs.readfile(rc_path):find(script_line, 1, true) then
            fs.writefile(rc_path, fs.readfile(rc_path):gsub("exit 0", script_line .. "\nexit 0"))
        end
    end

    -- Update the status after the service is toggled
    update_status()
end

return map

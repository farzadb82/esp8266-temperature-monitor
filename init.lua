-- luacheck: ignore wifi
-- luacheck: ignore node
-- luacheck: ignore file
-- luacheck: ignore adc
-- luacheck: ignore tmr
-- luacheck: ignore _

local _config = require("config")

local init_file = "temp_monitor.lua"

function runInitFile()
    if file.exists(init_file) then
        dofile(init_file)
    else
        print("\nCannot find init file: "..init_file);
    end
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T)
    print("\n\tSTA_CONNECTED" .. "\n\tSSID: " .. T.SSID .. "\n\tBSSID: " .. T.BSSID .. "\n\tChannel: " .. T.channel)
end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    print("\n\tSTA_DISCONNECTED" .. "\n\tSSID: " .. T.SSID .. "\n\tBSSID: " .. T.BSSID .. "\n\treason: " .. T.reason)
end)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    print("\n\tSTA_GOT_IP" .. "\n\tStation IP: " .. T.IP .. "\n\tSubnet mask: " .. T.netmask .. "\n\tGateway IP: " .. T.gateway)

    _, reset_reason = node.bootreason()
    if (reset_reason == 5) then
        runInitFile()
    else
        print("\n[" .. reset_reason .. "] Waiting 5s to start init file: " .. init_file .. " ...")
        tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
            runInitFile()
        end)
    end
end)

-- Switch the ADC mode so that we can read VDD
-- This needs a restart to properly enable
if adc.force_init_mode(adc.INIT_VDD33) then
    print("Switching ADC mode")
    node.restart()
    return -- don't bother continuing, the restart is scheduled
end

print("Connecting to " .. _config.WIFI_SSID)
wifi.setmode(wifi.STATION)
wifi.sta.config(_config.WIFI_SSID, _config.WIFI_PASSWORD)

init_file = "temp_monitor.lua"

function runInitFile()
    if file.exists(init_file) then
        dofile(init_file)
    else
        print("\nCannot find init file: "..init_file);
    end
end

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T) 
    print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\tChannel: "..T.channel)
end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T) 
    print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..T.BSSID.."\n\treason: "..T.reason)
end)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T) 
    print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..T.netmask.."\n\tGateway IP: "..T.gateway)

    _, reset_reason = node.bootreason()
    if (reset_reason == 5) then
        runInitFile()
    else
        print("\n["..reset_reason.."] Waiting 5s to start init file: "..init_file.." ...")
        tmr.alarm(0, 5000, tmr.ALARM_SINGLE, function()
            runInitFile()
        end)
    end
end)

WIFI_SSID = ""
WIFI_PASSWORD = ""
wifi.sta.config(WIFI_SSID, WIFI_PASSWORD)

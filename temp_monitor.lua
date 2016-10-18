-- Read temperature from DHT11/DHT22 temperature+humidity sensor

-- luacheck: ignore node
-- luacheck: ignore adc
-- luacheck: ignore tmr
-- luacheck: ignore _

local moduleName = "temp_monitor"
local M = {}
_G[moduleName] = M

local _config = require("config")

local _REFRESH_TIME = 60000000 -- in us

function M.send_data(temp, humidity, battery)
    local aio = require("aio")
    aio.init(_config.AIO_KEY)

    go_sleep = function(code, _)
        if (code < 200) then
            print("Failure code:" .. code)
        end
        if (code > 0) then
            print("Sent all data")
        else
            print("Failed to send data")
        end

        print("Going to sleep ...")
        node.dsleep(_REFRESH_TIME)
    end

    send_battery = function(code, _)
        if (code < 200) then
            print("Failure code:" .. code)
        end
        if (code > 0) then
            -- A short delay is needed between successive calls to http
            tmr.alarm(0, 100, tmr.ALARM_SINGLE, function()
                print("Sending battery voltage")
                aio.sendValue(battery, _config.AIO_FEED_BATTERY, go_sleep)
            end)
        end
    end

    send_humidity = function(code, _)
        if (code < 200) then
            print("Failure code:" .. code)
        end
        if (code > 0) then
            -- A short delay is needed between successive calls to http
            tmr.alarm(0, 100, tmr.ALARM_SINGLE, function()
                print("Sending temperature")
                aio.sendValue(temp, _config.AIO_FEED_TEMP, send_battery)
            end)
        end
    end

    print("Sending humidity")
    aio.sendValue(humidity, _config.AIO_FEED_HUMIDITY, send_humidity)
end

--load DHT module for read sensor
function M.read_dht()
    -- luacheck: ignore dht

    local _status, _t, _h, _b
    _status, _t, _h, _, _ = dht.read(_config.SENSOR_PIN)
    _b = adc.readvdd33(0)

    if _status == dht.OK then
        print("\nHumidity:    " .. _h .. "%")
        print("Temperature: " .. _t .. " deg C")
        print("Battery: " .. _b .. "mV")

        M.send_data(_t, _h, _b)
        return
    elseif _status == dht.ERROR_CHECKSUM then
        print("DHT Checksum error.")
    elseif _status == dht.ERROR_TIMEOUT then
        print("DHT timed out.")
    end

    -- If we get here (we shouldn't unless something broke!), reset everything
    tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function()
        print("Resetting NodeMCU")
        node.restart()
    end)
end

-- Every REFRESH_TIME get the new measurement and upload it
-- tmr.alarm(0, 100, tmr.ALARM_SINGLE, ReadDHT)
-- print("\nStarted Monitoring Temperature and Humidity every "..REFRESH_TIME.."ms ...")
-- tmr.alarm(0, REFRESH_TIME, tmr.ALARM_AUTO, ReadDHT)
M.read_dht()

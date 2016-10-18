local moduleName = "config"
local M = {}
_G[moduleName] = M

M.WIFI_SSID = ""
M.WIFI_PASSWORD = ""

M.AIO_KEY = ""
M.AIO_FEED_TEMP = "temp-1"
M.AIO_FEED_HUMIDITY = "humidity-1"
M.AIO_FEED_BATTERY = "battery-1"

M.SENSOR_PIN=4  -- data pin, GPIO0=3 GPIO2=4

return M

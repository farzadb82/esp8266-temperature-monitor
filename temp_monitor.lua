--    Test communication of DHT sensor
--    Tested with Lua NodeMCU 0.9.5 build 20150127 floating point !!!
-- 1. Flash Lua NodeMCU to ESP module.
-- 2. Set in program wots.lua humidity sensor type. This is parameter typeSensor="dht11" or "dht22".
-- 3. Load program wots.lua and testdht.lua to ESP8266 with LuaLoader
-- 4. HW reset module
-- 5. Run program wots.lua - dofile(wots.lua)

sensorType="dht11"
sensorPin=4 --  data pin, GPIO0=3 GPIO2=4

apiHost = "data.sparkfun.com"
apiPublicKey = ""
apiPrivateKey = ""
REFRESH_TIME = 60000

function sendData(temp, humidity)
    -- Establish connection
    phant = require("phant")
    phant.init(apiHost, apiPublicKey, apiPrivateKey)
    phant.add("humidity", humidity)
    phant.add("temp", temp)

    print("Sending data to "..apiHost)

    conn = net.createConnection(net.TCP, 0) 

    conn:on("receive", function(conn, payload)
                print("Received Response.")
                --print(payload)
            end)
    conn:on("sent", function(conn)
                print("Sent.")
                --conn:close()
            end)
    conn:on("disconnection", function(conn)
                print("Got disconnection.")
                node.dsleep(60000000)
            end)
    conn:on("connection", function(conn, payload)
                --print("\nSending:\n"..phant.post())
                conn:send(phant.post())
            end)
    conn:connect(80, apiHost)
end

--load DHT module for read sensor
function ReadDHT()
    dht=require(sensorType)
    dht.read(sensorPin)

    h=dht.getHumidity()
    t=dht.getTemperature()

    print("\nHumidity:    "..h.."%")
    print("Temperature: "..t.." deg C")

    sendData(t, h)

    -- release module
    dht=nil
    package.loaded[sensorType]=nil
end

-- Every REFRESH_TIME get the new measurement and upload it
--tmr.alarm(0, 100, tmr.ALARM_SINGLE, ReadDHT)
--print("\nStarted Monitoring Temperature and Humidity every "..REFRESH_TIME.."ms ...")
--tmr.alarm(0, REFRESH_TIME, tmr.ALARM_AUTO, ReadDHT)
ReadDHT()

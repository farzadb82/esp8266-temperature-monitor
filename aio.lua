-- adafruit.io module for NodeMCU
-- Requires http module

local moduleName = "aio"
local M = {}
_G[moduleName] = M

local _host;
local _key;
local _params;
local _headers;

function M._buildHeaders()
    local _msgHeaders = ""

    _headers["X-AIO-Key"] = _key
    _headers["Content-Type"] = "application/json"

    for key, value in pairs(_headers) do
        _msgHeaders = _msgHeaders .. key .. ": " .. value .. "\r\n"
    end

    return _msgHeaders
end

function M._contentToJSON(content)
    local _jsonStr = ""

    for key, value in pairs(content) do
        local _kind = type(value)
        if _kind == "number" then
            _jsonStr = _jsonStr .. "\"" .. key .. "\":" .. tostring(value) .. ","
        else
            _jsonStr = _jsonStr .. "\"" .. key .. "\":" .. "\"" .. value .. "\","
        end
    end

    return "{" .. string.sub(_jsonStr, 1, string.len(_jsonStr) - 1) .. "}"
end

function M.init(key)
    _host = "http://io.adafruit.com/api"
    _params = {};
    _headers = {};

    _key = key
end

function M.setLocation(lat, lon)
    _params["lat"] = lat
    _params["lon"] = lon
end

function M.sendValue(value, feed, response_fn)
    -- luacheck: ignore http

    _params["value"] = value

    local _url = _host .. "/feeds/" .. feed .. "/data"
    local _reqHeaders = M._buildHeaders()
    local _reqContent = M._contentToJSON(_params)

    -- print ("Posting " .. value .. " to " .. _url .. ": ")
    -- print ("  Headers: " .. _reqHeaders)
    -- print ("  Content: " .. _reqContent)

    http.post(_url, _reqHeaders, _reqContent, function(code, data)
        if response_fn then
            response_fn(code, data)
        end
    end)
end

return M

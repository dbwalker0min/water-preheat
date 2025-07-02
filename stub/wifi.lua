-- stub/wifi.lua

local wifi = {}

--- WiFi operation modes.
--- 

wifi.NULLMODE = 0
wifi.STATION = 1
wifi.SOFTAP = 2
wifi.STATIONAP = 3

--- Country info configuration table.
--- @class CountryInfo
--- @field country string Country code (e.g., "US").
--- @field start_ch number Starting channel.
--- @field end_ch number Ending channel.
--- @field policy number Policy for the country (0 = auto policy, 1 = manual).

--- Get the current WiFi channel
--- @return number The current WiFi channel (0 if not connected)
function wifi.getchannel() return 0 end

--- Get the current WiFi country information
--- @return CountryInfo country_info A table containing country information
function wifi.getcountry()
    return {
        country = "US",
        start_ch = 0,
        end_ch = 11,
        policy = 0
    }
end

--- Get default WiFi operation mode
--- @return number wifi_mode The default WiFi operation mode (wifi.NULLMODE, wifi.STATION, wifi.SOFTAP, or wifi.STATIONAP)
function wifi.getmode()
    return wifi.STATION
end

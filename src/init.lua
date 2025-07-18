---esp8266

print("Hello, World!")

local mode = wifi.getmode()
gpio.mode(1, gpio.FLOAT)
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid="walker3", pwd="dbwalker0min@gmail.com"})
wifi.sta.connect()

local timer = tmr.create()

timer:alarm(1000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() == nil then
        print("IP unavailable, Waiting...")
    else
        timer:unregister()
        print("Config done, IP is " .. wifi.sta.getip())
    end
end)
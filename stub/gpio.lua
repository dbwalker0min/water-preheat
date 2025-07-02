-- stub/gpio.lua

local gpio = {}

--- GPIO pin modes.
gpio.INPUT = 0
gpio.OUTPUT = 1
gpio.INT = 2
gpio.OPENDRAIN = 3

--- GPIO pin pull-up resistor settings.
gpio.FLOAT = 0
gpio.PULLUP = 1

--- GPIO pin values
gpio.HIGH = 1
gpio.LOW = 0

--- Sets the mode of a GPIO pin.
--- @param pin number GPIO pin number.
--- @param mode number Mode to set for the pin.
--- @param pullup? number Optional pull-up resistor setting (gpio.FLOAT [0] or gpio.PULLUP [1]).
function gpio.mode(pin, mode, pullup) end

--- Set the value of a GPIO pin.
--- @param pin number GPIO pin number.
--- @param value number Value to set for the pin (gpio.HIGH [1] or gpio.LOW [0]).
function gpio.write(pin, value) end

--- Read the value of a GPIO pin.
--- @param pin number GPIO pin number.
--- @return number Value of the pin (gpio.HIGH [1] or gpio.LOW [0]).
function gpio.read(pin) return gpio.LOW end

--- Establish or clear a callback function to run on interrupt for a GPIO pin.
--- @param pin number GPIO pin number.
--- @param type "none"|"up"|"down"|"both"|"low"|"high" Trigger modes.
--- @param callback function Callback function to run on interrupt. If nil, clears the callback.
function gpio.trig(pin, type, callback) end

--- Serialize output based on a sequence of delay-times in µs. After each delay, the pin is toggled. After the last cycle and last delay the pin is not toggled.

--- @param pin number GPIO pin number.
--- @param start_level number Initial level of the pin (gpio.HIGH [1] or gpio.LOW [0]).
--- @param delay_times table Table of delay times in µs.
--- @param cycle_num number? Option number of cycles to repeat the sequence.
--- @param callback function? Optional callback function to run after the sequence completes.
function gpio.serout(pin, start_level, delay_times, cycle_num, callback) end
return gpio

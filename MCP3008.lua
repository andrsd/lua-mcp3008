--
-- MCP3008
-- David Andrs, 2016
--
-- Based on the code by xraynaud from http://www.esp8266.com/viewtopic.php?f=19&t=9350
--

local MCP3008 = {}
MCP3008.__index = MCP3008
MCP3008.OK = 0
MCP3008.FAIL = -1

-- Create MCP3008
function MCP3008.new(clk, mosi, miso, cs)
	local self = setmetatable({}, MCP3008)

	self.CLK = clk
	self.MOSI = mosi
	self.MISO = miso
	self.CS = cs

	-- Pin initialization
	gpio.mode(self.CS, gpio.OUTPUT)
	gpio.mode(self.CLK, gpio.OUTPUT)
	gpio.mode(self.MOSI, gpio.OUTPUT)
	gpio.mode(self.MISO, gpio.INPUT)

	return self
end

-- Read channel
function MCP3008:read(ch)
	if ch >= 0 and ch < 8 then
		-- MCP3008 has eight channels 0-8
		gpio.write(self.CS, gpio.HIGH)
		tmr.delay(5)

		gpio.write(self.CLK, gpio.LOW)
		gpio.write(self.CS, gpio.LOW)      --> Activate the chip
		tmr.delay(1)                       --> 1 us delay

		local commandout = ch
		commandout = bit.bor(commandout, 0x18)
		commandout = bit.lshift(commandout, 3)
		for i = 1, 5 do
			if bit.band(commandout, 0x80) > 0 then
				gpio.write(self.MOSI, gpio.HIGH)
			else
				gpio.write(self.MOSI, gpio.LOW)
			end
			commandout = bit.lshift(commandout, 1)

			gpio.write(self.CLK, gpio.HIGH)
			tmr.delay(1)
			gpio.write(self.CLK, gpio.LOW)
			tmr.delay(1)
		end
		local adcout = 0
		for i = 1, 12 do
			gpio.write(self.CLK, gpio.HIGH)
			tmr.delay(1)
			gpio.write(self.CLK, gpio.LOW)
			tmr.delay(1)
			adcout = bit.lshift(adcout, 1);
			if gpio.read(self.MISO) > 0 then
				adcout = bit.bor(adcout, 0x1)
			end
		end
		gpio.write(self.CS, gpio.HIGH)
		adcout = bit.rshift(adcout, 1)
		return MCP3008.OK, adcout
	else
		return MCP3008.FAIL, 0
	end
end

return MCP3008

lua-mcp3008
===========

Reading values from MCP3008 in lua on nodemcu.

Usage
-----

This read value from channel 0:
```
local MCP3008 = require("MCP3008")

MISO = 6  --> GPIO12
MOSI = 5  --> GPIO14
CLK = 7   --> GPIO13
CS = 0    --> GPIO16

local mcp = MCP3008.new(CLK, MOSI, MISO, CS)
local status, value = mcp:read(0)
if status == MCP3008.OK then
	print(string.format("CH0 = %d\r\n", value))
else
	print("Error reading CH0\r\n")
end
```

Adjust MOSI, MISO, CLK and CS to your setup.

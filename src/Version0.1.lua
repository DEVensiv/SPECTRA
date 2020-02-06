component = require("component")
sensor = component.stargate

function getEntry()
	return sensor.bufferRead(1)[1]
end

function typeList()



end
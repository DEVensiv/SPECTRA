local component = require("component")
local classes = require("src/classes")

local gpu = component.gpu

local Ship = classes.class()

function Ship:init(shipControl)
    self.shipControl = shipControl
end

function Ship:shieldState()
    return "OFFLINE"
end

function Ship:cloakState()
    return "OFFLINE"
end

function Ship:shipState()
    return "IDLE"
end

function Ship:getLocation()
   if self.shipControl.isInHyperspace() then
      return "HYPERSPACE"
   end
   return "SPACE"
end

function Ship:getEnergy()
    local energy, maxenergy = self.shipControl.energy()
    return energy
end

function Ship:getRemoteLocation()
    return self.shipControl.getMaxJumpDistance()
end

function Ship:requiredEnergy()
    local success, result = self.shipControl.getEnergyRequired()
    if success then
      return result
    else
        return 0
    end
end

function Ship:enableShield(state)
    return
end

function Ship:toogleCloak()
    return
end

function Ship:terminateAll()
    self.shipControl.command("OFFLINE")
    self.shipControl.enable(false)
    require("computer").beep()
    return
end

function Ship:warp(f,u,s)
    self.shipControl.command("MANUAL")
    self.shipControl.movement(f,u,s)
    self.shipControl.enable(true)
end

function Ship:calcMovement(targetx,targety,targetz)
    
    self.shipControl.enable(false)
    self.shipControl.command("MANUAL")
    local forward = 0
    local side = 0
    local up = 0

    local dx,dy,dz = self.shipControl.getOrientation()
    local x,y,z = self.shipControl.position()
    
	ship_front, ship_right, ship_up = self.shipControl.dim_positive()
    ship_back, ship_left, ship_down = self.shipControl.dim_negative()
	
    local xmove = 0
    local ymove = 0
    local zmove = 0
    
    if type(targety) == "number" then
        ymove = targety - y
        up = ymove
    end
    
    if type(targetx) == "number" then
        xmove = targetx - x
        forward = (dx * xmove) - (dz * zmove)
    end
    
    if type(targetz) == "number" then
        zmove = targetz - z
        side = (dz * xmove) + (dx * zmove)
    end
    
	------------------------------------------------------------Minimal jump distance handler
	
	local min_forward = math.abs(ship_front + ship_back  + 1) + 1
	if forward ~= 0 and math.abs(forward) < min_forward then 
		if forward < 0 then
			forward = -min_forward
		else
			forward = min_forward
		end
	end
	
	local min_side = math.abs(ship_left  + ship_right + 1) + 1
	if side ~= 0 and math.abs(side) < min_side then 
		if side < 0 then
			side = -min_side
		else
			side = min_side
		end
	end
	
	local min_up = math.abs(ship_up    + ship_down  + 1) + 1
	if up ~= 0 and math.abs(up) < min_up then 
		if up < 0 then
			up = -min_up
		else
			up = min_up
		end
	end
	
	-----------------------------------------------------------Minimal jump distance handler end
	-----------------------------------------------------------Maximal jump distance handler
	
	local success, maxMove = self.shipControl.getMaxJumpDistance()
	if success then
		local max_dist_f = math.floor(math.abs(ship_front + ship_back + 1) + maxMove)
		if math.abs(forward) > max_dist_f then 
			if forward < 0 then
				forward = -max_dist_f
			else
				forward = max_dist_f
			end
		end
	
		local max_dist_s = math.floor(math.abs(ship_left + ship_right + 1) + maxMove)
		if math.abs(side) > max_dist_s then 
			if side < 0 then
				side = -max_dist_s
			else
				side = max_dist_s
			end
		end
	
		local max_dist_s = math.floor(math.abs(ship_up + ship_down + 1) + maxMove)
		if math.abs(up) > max_dist_s then 
			if up < 0 then
				up = -max_dist_s
			else
				up = max_dist_s
			end
		end
	
	end
	-----------------------------------------------------------Maximal jump distance handler end
	
    return forward, up, side
end

function Ship:hyperspace()
    self.shipControl.command("HYPERDRIVE")
    self.shipControl.enable(true)
    return
end

return Ship

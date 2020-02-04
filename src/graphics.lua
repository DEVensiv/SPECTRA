local graphics = {}

local component = require("component")

local gpu = component.gpu
local w, h = gpu.getResolution()

function graphics.draw()
  gpu.setBackground(BACKGROUND)
  gpu.fill(1, 1, w, h, " ")
  graphics.drawBorders()
  graphics.drawShip(50, 10)
  --graphics.drawShipControls()
  graphics.drawStatusWindow()
  graphics.drawRemoteInfo(4, 17)
  graphics.drawLocalInfo(4, 27)
end

function graphics.drawBorders()
  gpu.setBackground(CYAN)
  gpu.fill(1, 1, w, 1, " ")
  gpu.fill(1, 1, 1, h-2, " ")
  gpu.fill(1, h, w, h, " ")
  gpu.fill(w, 3, w-1, h, " ")
end

function graphics.drawShip(x,y)
  gpu.setBackground(GREY_DARK)
  
  --ship shape
  gpu.fill(x+21,y+4,12, 9, " ")
  gpu.fill(x+18, y+5, 26, 7, " ")
  gpu.fill(x+16, y+6, 2, 2, " ")
  gpu.fill(x+16, y+9, 2, 2, " ")
  gpu.fill(x+44, y+7, 3, 3, " ")
  gpu.fill(x+47, y+8, 1, 1, " ")

  --engines
  graphics.drawEngines(RED_DARK, x, y)
end

function graphics.drawShipControls()

end

function graphics.drawShield(x,y)
  gpu.setBackground(BLUE_LIGHT)
  gpu.fill(x + 2,y + 1 ,56, 13," ")
end

function graphics.drawEngines(color, x, y)
  gpu.setBackground(color)

  gpu.fill(x+20, y+4, 1, 1, " ")

  gpu.fill(x+15, y+6, 1, 2, " ")
  gpu.fill(x+15, y+9, 1, 2, " ")

  gpu.fill(x+20, y+12, 1, 1, " ")  
end

function graphics.drawWarpBubble(x,y)
  graphics.setBackground(RED)
  graphics.fill(x,y,60,15, " ")
  graphics.setBackground(BACKGROUND)
  graphics.fill(x+2, y+1, 56, 13, " ")
end

function graphics.drawStatusWindow()
  gpu.setBackground(CYAN)
  gpu.fill(40, 40, 80, 9, " ")
  gpu.setBackground(BACKGROUND)
  gpu.fill(40, 42, 80, 5, " ")
  gpu.fill(41, 41, 78, 1, " ")
  gpu.fill(41, 47, 78, 1, " ")
end

function graphics.drawStateMsg(state, space)
  -- clear previous message
  gpu.setBackground(BACKGROUND)
  gpu.fill(40, 42, 80, 5, " ")
  gpu.fill(41, 41, 78, 1, " ")
  gpu.fill(41, 47, 78, 1, " ")
  
  -- write message
  gpu.setBackground(RED)
  if state == "OFFLINE" then
    graphics.drawO(10)
    graphics.drawF(10+8)
    graphics.drawF(10+16)
    graphics.drawL(10+24)
    graphics.drawI(10+32)
    graphics.drawN(10+40)
    graphics.drawE(10+48)
  elseif state == "IDLE" then
    graphics.drawI(23)
    graphics.drawD(23+8)
    graphics.drawL(23+16)
    graphics.drawE(23+24)
  elseif state == "WARPING" then
    graphics.drawW(10)
    graphics.drawA(10+8)
    graphics.drawR(10+16)
    graphics.drawP(10+24)
    graphics.drawI(10+32)
    graphics.drawN(10+40)
    graphics.drawG(10+48)
  elseif state == "DOWN" then
    graphics.drawD(23)
    graphics.drawO(23+8)
    graphics.drawW(23+16)
    graphics.drawN(23+24)
  elseif state == "IDLE" and space == "HYPERSPACE" then
    graphics.drawH(0)
    graphics.drawY(8)
    graphics.drawP(16)
    graphics.drawE(24)
    graphics.drawR(32)
    graphics.drawS(40)
    graphics.drawP(48)
    graphics.drawA(56)
    graphics.drawC(64)
    graphics.drawE(72)
  end
end

function graphics.drawRemoteInfo(x, y, remotePos, energy)
  gpu.setBackground(CYAN)
  gpu.fill(x, y, 34, 8, " ")
  gpu.setBackground(BACKGROUND)
  gpu.fill(x+1, y+1, 32, 6, " ")
  gpu.setBackground(CYAN)
  gpu.setForeground(TEXT_WHITE)
  gpu.set(x + 17 - string.len("WARP DATA")/2, y+1, "WARP DATA")
  gpu.setBackground(BACKGROUND)

  if remotePos == nil then
    gpu.set(x+2, y+3, "LOCATION: INVALID")
  else
    gpu.set(x+2, y+3, "LOCATION: " .. tostring(remotePos))
  end
  
  if energy == nil then
    gpu.set(x+2, y+4, "ENERGY TO WARP: N/A")
  else
    gpu.set(x+2, y+4, "ENERGY TO WARP: " .. string.format("%e", math.floor(energy + 0.5)) .. " RF")
  end
  
end

function graphics.drawLocalInfo(x, y, energy, shield, err)
  gpu.setBackground(CYAN)
  gpu.fill(x, y, 34, 10, " ")
  gpu.setBackground(BACKGROUND)
  gpu.fill(x+1, y+1, 32, 8, " ")
  gpu.setBackground(CYAN)
  gpu.setForeground(TEXT_WHITE)
  gpu.set(x + 17 - string.len("SHIP DATA")/2, y+1, "SHIP DATA")
  gpu.setBackground(BACKGROUND)
  
  if energy == nil then
    gpu.set(x+2, y+3, "AVAILABLE ENERGY: N/A")
  else
    gpu.set(x+2, y+3, "AVAILABLE ENERGY: " .. string.format("%e", math.floor(energy + 0.5)) .. "  RF")
  end
  
  if iris == nil then
    gpu.set(x+2, y+5, "SHIELD STATE: UNKNOWN")
  else
    gpu.set(x+2, y+5, "SHIELD STATE: " .. shield)
  end
  
  gpu.set(x+2, y+6, "LAST ERROR:")
  if err == nil then
    gpu.setForeground(GREEN)
    gpu.set(x+2, y+7, "None")
  else
    gpu.setForeground(RED_DARK)
    gpu.set(x+2, y+7, err)
  end
end

function graphics.drawA(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 44, 6, 1, " ")
  gpu.fill(47+offset, 42, 2, 5, " ")
end

function graphics.drawC(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
end

function graphics.drawD(offset)
  gpu.fill(43+offset, 42, 4, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 46, 4, 1, " ")
  gpu.fill(47+offset, 43, 2, 3, " ")
end

function graphics.drawE(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 44, 4, 1, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
end

function graphics.drawF(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 44, 4, 1, " ")
end

function graphics.drawG(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
  gpu.fill(47+offset, 42, 2, 2, " ")
  gpu.fill(46+offset, 45, 3, 2, " ")
end

function graphics.drawI(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(45+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
end

function graphics.drawL(offset)
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
end

function graphics.drawM(offset)
  gpu.fill(43+offset, 42, 2, 1, " ")
  gpu.fill(42+offset, 42, 2, 5, " ")
  gpu.fill(47+offset, 42, 2, 1, " ")
  gpu.fill(48+offset, 42, 2, 5, " ")
  gpu.fill(45+offset, 43, 2, 1, " ")
end

function graphics.drawN(offset)
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(47+offset, 42, 2, 5, " ")
  gpu.fill(45+offset, 43, 1, 1, " ")
  gpu.fill(45+offset, 44, 2, 1, " ")
  gpu.fill(46+offset, 45, 1, 1, " ")
end

function graphics.drawO(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
  gpu.fill(47+offset, 42, 2, 5, " ")
end

function graphics.drawP(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 5, " ")
  gpu.fill(43+offset, 44, 6, 1, " ")
  gpu.fill(47+offset, 42, 2, 3, " ")
end

function graphics.drawS(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(43+offset, 42, 2, 3, " ")
  gpu.fill(43+offset, 44, 6, 1, " ")
  gpu.fill(47+offset, 44, 2, 3, " ")
  gpu.fill(43+offset, 46, 6, 1, " ")
end

function graphics.drawT(offset)
  gpu.fill(43+offset, 42, 6, 1, " ")
  gpu.fill(45+offset, 42, 2, 5, " ")
end

return graphics

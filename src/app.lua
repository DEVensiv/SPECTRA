local app = {}

local component = require("component")
local term = require("term")
local event = require("event")
local thread = require("thread")
local shell = require("shell")

function app.run()

-- colors
BACKGROUND =    0x000000  -- screen background
TEXT_WHITE =    0xFFFFFF  -- color of text
CYAN_LIGHT =    0x65D1D4  -- gate rings
SLATE_LIGHT =   0x569D95  -- gate controls
RED_DARK =      0x860007  -- chevrons
CYAN =          0x339D8F  -- GUI elements
GREY_DARK =     0x353535  -- gate cross
RED =           0xCC0001  -- status text
RED_BRIGHT =    0xFF0000  -- engaged chevrons
BLUE_LIGHT =    0x75BEC7  -- iris blade borders
BLUE_DARK =     0x2B586B  -- iris
BLUE =          0x2866A6  -- wormhole
GREY =          0x505050  -- disabled controls background
GREY_LIGHT =    0xA0A0A0  -- disabled controls foreground
GREEN =         0x2F8C45  -- no error

local graphics = require("src/graphics")
local Button = require("src/Button")
local InputField = require("src/InputField")
local BigInputField = require("src/BigInputField")

local Ship_main = require("src/Ship")
local gpu = component.gpu

Ship = Ship_main.new(component.getPrimary("warpdriveShipController"))
-- draw static graphics
graphics.draw()

-- create control elements

-- exit button
local w, h = component.gpu.getResolution()
local exitBtn = Button.new(w - 5, 1, 5, 1, "X", RED_DARK, TEXT_WHITE)
function updateExitBtn()
  exitBtn:setBackground(RED_DARK)
end
updateExitBtn()

-- Shield button
local shieldBtn = Button.new(4, 3, 16, 3, "SHIELD", CYAN, TEXT_WHITE)
function updateshieldBtn()
  shieldBtn:setBackground(CYAN)
  local shieldState = Ship:shieldState()
  if shieldState == "ON" then
    shieldBtn:setLabel("DISABLE SHIELD")
    shieldBtn:unlock()
  elseif shieldState == "OFF" then
    shieldBtn:setLabel("ENABLE SHIELD")
    shieldBtn:unlock()
  elseif shieldState == "OFFLINE" then
    shieldBtn:setLabel("NO SHIELD")
    shieldBtn:lock()
  end
end
updateshieldBtn()

-- cloak button
local cloakBtn = Button.new(22, 3, 16, 3, "CLOAK", CYAN, TEXT_WHITE)
function updateCloakBtn()
  local cloakState = Ship:cloakState() 
  if(cloakState == "OFF") then
    cloakBtn:setLabel("CLOAK")
    cloakBtn:setBackground(CYAN_LIGHT)
  elseif(cloakState == "ON") then
    cloakBtn:setLabel("UNCLOAK")
    cloakBtn:setBackground(CYAN)
  elseif cloakState == "OFFLINE" then
    cloakBtn:lock()
  else
    cloakBtn:unlock()
  end
end
updateCloakBtn()

-- x field
local XFld = InputField.new(4, 7, 15, 5, "X", CYAN, TEXT_WHITE, BACKGROUND)
XFld:draw()

-- z field
local ZFld = InputField.new(4 + 17, 7, 15, 5, "Z", CYAN, TEXT_WHITE, BACKGROUND)
ZFld:draw()

-- warp button
local warpBtn = Button.new(4, 13, 16, 3, "WARP", CYAN, TEXT_WHITE)
function updateDialBtn()
  warpBtn:setBackground(CYAN)
  local shipState = Ship:shipState()
  if shipState ~= "WARPING" then
    warpBtn:unlock()
  else
    warpBtn:lock()
  end
end
updateDialBtn()

-- terminate button
local terminateBtn = Button.new(22, 13, 16, 3, "TERMINATE", RED_DARK, TEXT_WHITE)
function updateTerminateBtn()
  terminateBtn:setBackground(RED_DARK)
  local ShipState = Ship:shipState()
  terminateBtn:unlock()
  
end
updateTerminateBtn()

-- y field
local YFld = InputField.new(4, 39, 34, 5, "Y", CYAN, TEXT_WHITE, BACKGROUND)
gpu.set(17-4, 38, "Y Position")
YFld:draw()

-- hyperspace button
local hyperBtn = Button.new(4, 39 + 6, 34, 3, "HYPERSPACE", CYAN, TEXT_WHITE)
hyperBtn:draw()

-- IDC field
--local BigInputField = BigInputField.new(61, 14, 40, 22, "VALID IDCS", CYAN, TEXT_WHITE, BACKGROUND, stargate.getValidIDCs())

-- main loop
local lastErr = nil
local run = true
local t = nil
while run do
  -- update gate and iris state
  local ShipState = Ship:shipState()
  local shieldState = Ship:shieldState()
 
  -- draw state message
  graphics.drawStateMsg(ShipState, Ship:getLocation())
  
  if(ShipState == "WARPING") then
    graphics.drawWarpBubble(50, 10)
  end

  if(shieldState == "ON") then
    graphics.drawShield(50, 10)
  end

  graphics.drawShip(50,10)

  if(ShipState == "WARPING") then
    graphics.drawEngines(RED_BRIGHT, 50,10)
  end

  local params = { event.pull(1, "shipCoreCooldownDone") }
  local eventName = params[1]
  
  -- get clicks
  local _, _, x, y = event.pull(1, "touch")
  

  if tostring(eventName) == "shipCoreCooldownDone" then
	os.execute("reboot")
  end
  
  -- update control elements
  graphics.drawRemoteInfo(4, 17, Ship:getRemoteLocation(), Ship:requiredEnergy())
  graphics.drawLocalInfo(4, 27, Ship:getEnergy(), shieldState, lastErr)
  
  -- exit button
  updateExitBtn()
  if exitBtn:clicked(x, y) then
    exitBtn:setBackground(RED_BRIGHT)
	os.execute("pastebin run -f paUSHQQC DEVensiv SPECTRA master")
	
	shell.setWorkingDirectory("/SPECTRA")

	local move = function(von, nach) fs.remove(nach) fs.rename(von, nach) print(string.format("%s → %s", fs.canonical(von), fs.canonical(nach))) end

	if fs.exists("/SPECTRA/autorun.lua") then
		move("/SPECTRA/autorun.lua", "/autorun.lua")
	end
	
    run = false
  end
  
  -- shield button
  updateshieldBtn()
  if shieldBtn:clicked(x, y) then
    shieldBtn:setBackground(CYAN_LIGHT)
    if shieldState == "OFF" then
      shieldBtn:setLabel("ENABLE SHIELD")
      Ship:enableShield(true)
    else
      shieldBtn:setLabel("DISABLE SHIELD")
      Ship:enableShield(false)
    end
  end
  
  -- cloak button
  updateCloakBtn()
  if cloakBtn:clicked(x, y) then
    Ship:toogleCloak()
  end
  
  -- terminate button
  updateTerminateBtn()
  if terminateBtn:clicked(x, y) then
    Ship:terminateAll()
  end
  
  -- X field
  if XFld:clicked(x, y) then
    XFld:clear()
    XFld:readInput()
  end

   -- Y field
   if YFld:clicked(x, y) then
     YFld:clear()
     YFld:readInput()
   end
  
  -- Z field
  if ZFld:clicked(x, y) then
    ZFld:clear()
    ZFld:readInput()
  end

  -- cloak field
--  if autocloseFld:clicked(x,y) then
--    autocloseFld:clear()
--    autocloseFld:readInput()
--  end

-- warp button
  updateDialBtn()
  if warpBtn:clicked(x, y) then
    warpBtn:setBackground(CYAN_LIGHT)
    local f,u,s = Ship:calcMovement(tonumber(XFld.raw), tonumber(YFld.raw), tonumber(ZFld.raw))

    Ship:warp(f,u,s)
  end
  
  -- hyperspace button
  if hyperBtn:clicked(x, y) then
    hyperBtn:setBackground(CYAN_LIGHT)
    Ship:hyperspace()  
  end
  
end

-- reset colors
component.gpu.setBackground(0x000000)
component.gpu.setForeground(0xFFFFFF)

-- clear everything
term.clear();

end

return app
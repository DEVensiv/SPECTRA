local component = require("component")
local classes = require("src/classes")
local event = require("event")

local gpu = component.gpu

local InputField = classes.class()

function InputField:init(x, y, w, h, text, bg, fg, textBg)
  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.text = text
  self.bg = bg
  self.fg = fg
  self.textBg = textBg
  self.address = ""
  self.raw = text
  self.locked = false
end

function InputField:draw()
  gpu.setBackground(self.bg)
  gpu.fill(self.x, self.y, self.w, self.h, " ")
  
  gpu.setBackground(self.textBg)
  gpu.fill(self.x + 1, self.y + 1, self.w - 2, self.h - 2, " ")
  
  gpu.setForeground(self.fg)
  gpu.set(self.x + self.w/2 - string.len(self.text)/2, self.y + self.h/2, self.text)
end

function InputField:setLabel(text)
  self.text = text
  self:draw()
end

function InputField:clicked(x, y)
  if not x or not y then
    return false
  end
  if self.locked then
    return false
  end
  if x >= self.x + 1 and x < (self.x + self.w - 2) and y >= self.y + 1 and y < (self.y + self.h - 2) then
    return true
  else
    return false
  end
end

function InputField:clear()
   self.text = ""
   self.raw = ""
   self:draw()
end

function InputField:readInput()
  local typing = true
  
  while typing do
    self:setLabel(self.raw)
    local _,_,key = event.pull("key_down")
    
    -- letters/numbers
    if key >= 48 and key <= 57 then
      self.raw = self.raw .. string.char(key)
    elseif key >= 97 and key <= 122 then
      self.raw = self.raw .. string.char(key - 32)
    elseif key == 8 and string.len(self.raw) > 0 then
      self.raw = self.raw:sub(1, -2)
    elseif key == 13 then
      self:setLabel(self.raw)
      typing = false
    else
	  self.raw = self.raw .. string.char(key)
	end
  end
end

return InputField
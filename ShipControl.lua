local component = require("component")
local shell = require("shell")
local fs = require("filesystem")
local seria = require("serialization")

if not component.isAvailable("gpu") then
  io.stderr:write("GPU not found\n")
  return
end

shell.setWorkingDirectory("/SPECTRA")

local move = function(von, nach) fs.remove(nach) fs.rename(von, nach) print(string.format("%s → %s", fs.canonical(von), fs.canonical(nach))) end

if fs.exists("/SPECTRA/autorun.lua") then
	move("/SPECTRA/autorun.lua", "/autorun.lua")
end

local app = require("src/app")
app.run()
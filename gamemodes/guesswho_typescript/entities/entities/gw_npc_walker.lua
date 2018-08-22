
-- Lua Library Imports
local exports = exports or {}
AddCSLuaFile()
ENT.Base = "base_nextbot"
function ENT.Initialize(self)
    self:SetModel("test")
end
return exports


-- Lua Library Imports
local exports = exports or {}
AddCSLuaFile()
local GWGameState={}
GWGameState.NONE=0
GWGameState.MESH_GENERATION=1
GWGameState.WAITING=2
GWGameState.CREATING=3
GWGameState.HIDING=4
GWGameState.SEEKING=5
GWGameState.POST_ROUND=6
exports.GWGameState = GWGameState
return exports

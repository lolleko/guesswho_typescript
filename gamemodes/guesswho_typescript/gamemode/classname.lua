
-- Lua Library Imports
local exports = exports or {}
AddCSLuaFile()
local GWClassName={}
GWClassName.NPC_WALKER="gw_npc_walker"
GWClassName.HIDER_PLAYER_CLASS="gw_player_hider"
GWClassName.SEEKER_PLAYER_CLASS="gw_player_seeker"
GWClassName.ENT_GAMERULES="gw_gamerules"
exports.GWClassName = GWClassName
return exports

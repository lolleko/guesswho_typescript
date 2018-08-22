
-- Lua Library Imports
local exports = exports or {}
AddCSLuaFile()
local GWClassNames={}
GWClassNames.NPC_WALKER="gw_npc_walker"
GWClassNames.HIDER_PLAYER_CLASS="gw_player_hider"
GWClassNames.SEEKER_PLAYER_CLASS="gw_player_seeker"
GWClassNames.ENT_GAMERULES="gw_gamerules"
exports.GWClassNames = GWClassNames
return exports

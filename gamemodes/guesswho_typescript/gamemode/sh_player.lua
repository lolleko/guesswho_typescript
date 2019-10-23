--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
AddCSLuaFile();
local __meta__Player = debug.getregistry().Player;
__meta__Player.IsHider = function(self)
    return self:Team() == HIDER;
end;
__meta__Player.IsSeeker = function(self)
    return self:Team() == SEEKER;
end;

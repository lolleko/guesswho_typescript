--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
-- Lua Library inline imports
__TS__ArrayForEach = function(arr, callbackFn)
    do
        local i = 0;
        while i < (#arr) do
            callbackFn(_G, arr[i + 1], i, arr);
            i = i + 1;
        end
    end
end;

GWHUD = GWHUD or {};
GWHUD.__index = GWHUD;
GWHUD.prototype = GWHUD.prototype or {};
GWHUD.prototype.__index = GWHUD.prototype;
GWHUD.prototype.constructor = GWHUD;
GWHUD.new = function(...)
    local self = setmetatable({}, GWHUD.prototype);
    self:____constructor(...);
    return self;
end;
GWHUD.prototype.____constructor = function(self)
    self.AbilityIcons = {};
    local icons = ({file.Find("materials/vgui/gw/abilityicons/*.png", "GAME")})[0 + 1];
    __TS__ArrayForEach(icons, function(____, iconFile)
        return (function(o, i, v)
            o[i] = v;
            return v;
        end)(self.AbilityIcons, string.StripExtension(iconFile), Material("materials/vgui/gw/abilityicons/" .. iconFile, "noclamp smooth"));
    end);
end;
GWHUD.GetInstance = function(self)
    if not GWHUD.instance then
        GWHUD.instance = GWHUD.new();
    end
    return GWHUD.instance;
end;
GWHUD.prototype.Paint = function(self)
    if GetConVar("cl_drawhud"):GetInt() == 0 then
        if self.portrait then
            self.portrait:Remove();
            self.portrait = nil;
        end
    end
    local localPly = LocalPlayer();
    local isSpectating = (not localPly:Alive()) and IsValid(localPly:GetObserverTarget());
    if isSpectating then
        self.hudTarget = localPly:GetObserverTarget();
    else
        self.hudTarget = localPly;
    end
    self.teamColor = team.GetColor(self.hudTarget:Team());
    self:PaintTopBar();
end;
GWHUD.prototype.PaintTopBar = function(self)
    local timeInSeconds = string.ToMinutesSeconds((GAMEMODE).Gamerules.GameTime);
    local label = (GAMEMODE).Gamerules.GameStateLabel;
end;
hook.Add("HUDPaint", "GWHUD", function()
    return GWHUD:GetInstance():Paint();
end);

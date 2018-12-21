GWHUD = GWHUD or {}
GWHUD.__index = GWHUD
function GWHUD.new(construct, ...)
    local self = setmetatable({}, GWHUD)
    if construct and GWHUD.constructor then GWHUD.constructor(self, ...) end
    return self
end
function GWHUD.constructor(self)
    self.AbilityIcons = {};
    local icons = ({ file.Find("materials/vgui/gw/abilityicons/*.png","GAME") })[(0)+1];
    icons:forEach(function(iconFile) return (function(o, i, v) o[i] = v; return v end)(self.AbilityIcons, string.StripExtension(iconFile), Material("materials/vgui/gw/abilityicons/" .. iconFile,"noclamp smooth")) end);
end

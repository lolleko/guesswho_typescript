--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
GWIconButton = GWIconButton or {};
GWIconButton.__index = GWIconButton;
GWIconButton.prototype = GWIconButton.prototype or {};
GWIconButton.prototype.__index = GWIconButton.prototype;
GWIconButton.prototype.constructor = GWIconButton;
GWIconButton.new = function(...)
    local self = setmetatable({}, GWIconButton.prototype);
    self:____constructor(...);
    return self;
end;
GWIconButton.prototype.____constructor = function(self)
end;
GWIconButton.prototype.SetColor = function(self, color)
    self.color = color;
end;
GWIconButton.prototype.SetIconSize = function(self, size)
    self:SetFont("GWIcon" .. size);
    self:SetSize(size, size);
end;
GWIconButton.prototype.Init = function(self)
    self.color = Color(0, 0, 0, 0);
    self:SetAllowNonAsciiCharacters(true);
    self:SetTextColor(Color(255, 255, 255));
    self:SetContentAlignment(5);
end;
GWIconButton.prototype.Paint = function(self, width, height)
    draw.RoundedBox(width / 2, 0, 0, width, height, self.color);
    return false;
end;
vgui.Register("GWIconButton", GWIconButton, "DButton");

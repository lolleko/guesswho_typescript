GWIconButton = GWIconButton or {}
GWIconButton.__index = GWIconButton
function GWIconButton.new(construct, ...)
    local self = setmetatable({}, GWIconButton)
    if construct and GWIconButton.constructor then GWIconButton.constructor(self, ...) end
    return self
end
function GWIconButton.constructor(self)
end
function GWIconButton.SetColor(self,color)
    self.color = color;
end
function GWIconButton.SetIconSize(self,size)
    self:SetFont("GWIcon" .. size);
    self:SetSize(size,size);
end
function GWIconButton.Init(self)
    self.color = Color(0,0,0,0);
    self:SetAllowNonAsciiCharacters(true);
    self:SetTextColor(Color(255,255,255));
    self:SetContentAlignment(5);
end
function GWIconButton.Paint(self,width,height)
    draw.RoundedBox(width/2,0,0,width,height,self.color);
    return false
end
vgui.Register("GWIconButton",GWIconButton,"DButton");

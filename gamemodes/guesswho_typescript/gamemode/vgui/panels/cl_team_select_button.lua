GWTeamSelectButton = GWTeamSelectButton or {}
GWTeamSelectButton.__index = GWTeamSelectButton
function GWTeamSelectButton.new(construct, ...)
    local self = setmetatable({}, GWTeamSelectButton)
    if construct and GWTeamSelectButton.constructor then GWTeamSelectButton.constructor(self, ...) end
    return self
end
function GWTeamSelectButton.constructor(self)
end
function GWTeamSelectButton.SetTeam(self,teamIndex)
    self.color = team.GetColor(teamIndex);
    self.team = teamIndex;
    local configData = GWConfigManager:GetInstance():get__Data();
    if teamIndex==HIDER then
        self.modelPanel:SetModel(configData.HiderModels[(math.random(#configData.HiderModels)-1)+1]);
        self.teamIcon:SetText(utf8.char(57431));
        self.teamName:SetText("HIDER");
    elseif teamIndex==SEEKER then
        self.modelPanel:SetModel(configData.SeekerModels[(math.random(#configData.SeekerModels)-1)+1]);
        self.teamIcon:SetText(utf8.char(57409));
        self.teamName:SetText("SEEKER");
    end
end
function GWTeamSelectButton.Init(self)
    self.color = Color(0,0,0);
    self:SetSize(ScrW()/2,ScrH());
    self.modelPanel = vgui.Create("DModelPanel",self);
    self.modelPanel:SetMouseInputEnabled(false);
    self.modelPanel:Dock(FILL);
    self.headerContainer = vgui.Create("DPanel",self);
    self.headerContainer:SetPaintBackground(false);
    self.headerContainer:SetSize(self:GetWide(),384);
    self.headerContainer:SetPos(0,ScrH()-384);
    self.headerContainer:SetMouseInputEnabled(false);
    self.teamIcon = vgui.Create("GWIconButton",self.headerContainer);
    self.teamIcon:SetIconSize(GWFontSize.Huge);
    self.teamIcon:Center();
    self.teamName = vgui.Create("DLabel",self.headerContainer);
    self.teamName:SetTextColor(Color(255,255,255));
    self.teamName:SetHeight(128);
    self.teamName:SetFont("GWDefault" .. GWFontSize.Large);
    self.teamName:SetContentAlignment(2);
    self.teamName:DockMargin(0,0,0,10);
    self.teamName:Dock(BOTTOM);
end
function GWTeamSelectButton.Paint(self,width,height)
    draw.RoundedBox(0,0,0,width,height,self.color);
    return false
end
function GWTeamSelectButton.DoClick(self)
    if (GAMEMODE):IsBalancedToJoin(self.team) then
        GAMEMODE:HideTeam();
        RunConsoleCommand("changeteam",self.team);
    end
end
vgui.Register("GWTeamSelectButton",GWTeamSelectButton,"DButton");

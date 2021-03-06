--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
GWTeamSelectScreen = GWTeamSelectScreen or {};
GWTeamSelectScreen.__index = GWTeamSelectScreen;
GWTeamSelectScreen.prototype = GWTeamSelectScreen.prototype or {};
GWTeamSelectScreen.prototype.__index = GWTeamSelectScreen.prototype;
GWTeamSelectScreen.prototype.constructor = GWTeamSelectScreen;
GWTeamSelectScreen.new = function(...)
    local self = setmetatable({}, GWTeamSelectScreen.prototype);
    self:____constructor(...);
    return self;
end;
GWTeamSelectScreen.prototype.____constructor = function(self)
end;
GWTeamSelectScreen.prototype.Init = function(self)
    self:SetSize(ScrW(), ScrH());
    self:SetPos(0, 0);
    self:MakePopup();
    self:SetKeyboardInputEnabled(false);
    local headerImage = vgui.Create("DImage", self);
    headerImage:SetSize(427.5, 144);
    headerImage:SetPos(0, 40);
    headerImage:SetImage("vgui/gw/logo_main.png");
    headerImage:CenterHorizontal();
    headerImage:SetZPos(10);
    local hiderButton = vgui.Create("GWTeamSelectButton", self);
    hiderButton:SetTeam(HIDER);
    local seekerButton = vgui.Create("GWTeamSelectButton", self);
    seekerButton:SetPos(ScrW() / 2, 0);
    seekerButton:SetTeam(SEEKER);
    local closeButton = vgui.Create("GWIconButton", self);
    closeButton:SetText(utf8.char(57447));
    closeButton:SetIconSize(GWFontSize.Small);
    closeButton:SetPos(ScrW() - (40 + closeButton:GetWide()), 40);
    closeButton:SetTooltip("Close");
    closeButton.DoClick = function(____)
        return GAMEMODE:HideTeam();
    end;
    closeButton:SetZPos(10);
    local helpButton = vgui.Create("GWIconButton", self);
    helpButton:SetText(utf8.char(57402));
    helpButton:SetIconSize(GWFontSize.Small);
    helpButton:SetPos(ScrW() - ((40 + closeButton:GetWide()) * 3), 40);
    helpButton:SetTooltip("Help");
    helpButton.DoClick = function(____)
        RunConsoleCommand("changeteam", TEAM_SPECTATOR);
        GAMEMODE:HideTeam();
    end;
    helpButton:SetZPos(10);
    local configButton = vgui.Create("GWIconButton", self);
    configButton:SetText(utf8.char(57426));
    configButton:SetIconSize(GWFontSize.Small);
    configButton:SetPos(ScrW() - ((40 + closeButton:GetWide()) * 2), 40);
    configButton:SetTooltip("Config");
    configButton.DoClick = function(____)
        RunConsoleCommand("changeteam", TEAM_SPECTATOR);
        GAMEMODE:HideTeam();
    end;
    configButton:SetZPos(10);
    local spectateButton = vgui.Create("GWIconButton", self);
    spectateButton:SetText("O");
    spectateButton:SetIconSize(GWFontSize.Small);
    spectateButton:SetPos(ScrW() - ((40 + closeButton:GetWide()) * 4), 40);
    spectateButton:SetTooltip("Spectate");
    spectateButton.DoClick = function(____)
        RunConsoleCommand("changeteam", TEAM_SPECTATOR);
        GAMEMODE:HideTeam();
    end;
    spectateButton:SetZPos(10);
end;
vgui.Register("GWTeamSelectScreen", GWTeamSelectScreen, "DPanel");

class GWTeamSelectScreen extends DPanel {
    public Init(): void {
        this.SetSize(ScrW(), ScrH());
        this.SetPos(0, 0);
        this.MakePopup();
        this.SetKeyboardInputEnabled(false);

        const headerImage = vgui.Create("DImage", this) as DImage;
        headerImage.SetSize(427.5, 144);
        headerImage.SetPos(0, 40);
        headerImage.SetImage("vgui/gw/logo_main.png");
        headerImage.CenterHorizontal();
        headerImage.SetZPos(10);

        const hiderButton = vgui.Create("GWTeamSelectButton", this) as GWTeamSelectButton;
        hiderButton.SetTeam(TEAM.HIDER);

        const seekerButton = vgui.Create("GWTeamSelectButton", this) as GWTeamSelectButton;
        seekerButton.SetPos(ScrW() / 2, 0);
        seekerButton.SetTeam(TEAM.SEEKER);

        const closeButton = vgui.Create("GWIconButton", this) as GWIconButton;
        closeButton.SetText(utf8.char(0xE067));
        closeButton.SetIconSize(GWFontSize.Small);
        closeButton.SetPos(ScrW() - (40 + closeButton.GetWide()), 40);
        closeButton.SetTooltip("Close");
        closeButton.DoClick = () => GAMEMODE.HideTeam();
        closeButton.SetZPos(10);

        const helpButton = vgui.Create("GWIconButton", this) as GWIconButton;
        helpButton.SetText(utf8.char(0xE03A));
        helpButton.SetIconSize(GWFontSize.Small);
        helpButton.SetPos(ScrW() - ((40 + closeButton.GetWide()) * 3), 40);
        helpButton.SetTooltip("Help");
        helpButton.DoClick = () => {
            RunConsoleCommand("changeteam", TEAM.TEAM_SPECTATOR);
            GAMEMODE.HideTeam();
        };
        helpButton.SetZPos(10);

        const configButton = vgui.Create("GWIconButton", this) as GWIconButton;
        configButton.SetText(utf8.char(0xE052));
        configButton.SetIconSize(GWFontSize.Small);
        configButton.SetPos(ScrW() - ((40 + closeButton.GetWide()) * 2), 40);
        configButton.SetTooltip("Config");
        configButton.DoClick = () => {
            RunConsoleCommand("changeteam", TEAM.TEAM_SPECTATOR);
            GAMEMODE.HideTeam();
        };
        configButton.SetZPos(10);

        const spectateButton = vgui.Create("GWIconButton", this) as GWIconButton;
        spectateButton.SetText("O");
        spectateButton.SetIconSize(GWFontSize.Small);
        spectateButton.SetPos(ScrW() - ((40 + closeButton.GetWide()) * 4), 40);
        spectateButton.SetTooltip("Spectate");
        spectateButton.DoClick = () => {
            RunConsoleCommand("changeteam", TEAM.TEAM_SPECTATOR);
            GAMEMODE.HideTeam();
        };
        spectateButton.SetZPos(10);
    }
}

vgui.Register("GWTeamSelectScreen", GWTeamSelectScreen, "DPanel");

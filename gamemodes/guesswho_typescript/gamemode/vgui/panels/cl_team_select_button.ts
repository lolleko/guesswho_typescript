class GWTeamSelectButton extends DButton {

    private color: Color;

    private modelPanel: DModelPanel;

    private team: TEAM;

    private headerContainer: DPanel;

    private teamIcon: GWIconButton;

    private teamName: DLabel;

    public SetTeam(teamIndex: TEAM): void {
        this.color = team.GetColor(teamIndex);
        this.team = teamIndex;
        const configData = GWConfigManager.GetInstance().Data;

        if (teamIndex === TEAM.HIDER) {
            this.modelPanel.SetModel(configData.HiderModels[math.random(configData.HiderModels.length) - 1]);
            this.teamIcon.SetText(utf8.char(0xE057));
            this.teamName.SetText("HIDER");
        } else if (teamIndex === TEAM.SEEKER) {
            this.modelPanel.SetModel(configData.SeekerModels[math.random(configData.SeekerModels.length) - 1]);
            this.teamIcon.SetText(utf8.char(0xE041));
            this.teamName.SetText("SEEKER");
        }
    }

    public Init(): void {
        this.color = Color(0, 0, 0);
        this.SetSize(ScrW() / 2, ScrH());

        this.modelPanel = vgui.Create("DModelPanel", this) as DModelPanel;
        this.modelPanel.SetMouseInputEnabled(false);
        this.modelPanel.Dock(DOCK.FILL);

        this.headerContainer = vgui.Create("DPanel", this) as DPanel;
        this.headerContainer.SetPaintBackground(false);
        this.headerContainer.SetSize(this.GetWide(), 384);
        this.headerContainer.SetPos(0, ScrH() - 384);
        this.headerContainer.SetMouseInputEnabled(false);

        this.teamIcon = vgui.Create("GWIconButton", this.headerContainer) as GWIconButton;
        this.teamIcon.SetIconSize(GWFontSize.Huge);
        this.teamIcon.Center();

        this.teamName = vgui.Create("DLabel", this.headerContainer) as DLabel;
        this.teamName.SetTextColor(Color(255, 255, 255));
        this.teamName.SetHeight(128);
        this.teamName.SetFont("GWDefault" + GWFontSize.Large);
        this.teamName.SetContentAlignment(2);
        this.teamName.DockMargin(0, 0, 0, 10);
        this.teamName.Dock(DOCK.BOTTOM);
    }

    public Paint(width: number, height: number): boolean {
        draw.RoundedBox(0, 0, 0, width, height, this.color);
        return false;
    }

    public DoClick(): void {
        if ((GAMEMODE as GWGamemodeCL).IsBalancedToJoin(this.team)) {
            GAMEMODE.HideTeam();
            RunConsoleCommand("changeteam", this.team);
        }
    }
}

vgui.Register("GWTeamSelectButton", GWTeamSelectButton, "DButton");

class GWHUD {
    private AbilityIcons: {[key: string]: IMaterial};

    private portrait?: DModelPanel;

    private hudTarget: Player;

    private teamColor: Color;

    private constructor() {
        this.AbilityIcons = {};
        const icons = file.Find("materials/vgui/gw/abilityicons/*.png", "GAME")[0];
        icons.forEach(
            (iconFile: string) =>
                this.AbilityIcons[string.StripExtension(iconFile)] =
                    new IMaterial("materials/vgui/gw/abilityicons/" + iconFile, "noclamp smooth"));
    }
    
    public static GetInstance(): GWHUD {
        if (!GWHUD.instance) {
            GWHUD.instance = new GWHUD();
        }
        return GWHUD.instance;
    }

    private static instance: GWHUD;

    public Paint(): void {
    
        if (GetConVar("cl_drawhud").GetInt() == 0) {
            if (this.portrait) {
                this.portrait.Remove()
                this.portrait = undefined;
            }
        }

        const localPly = LocalPlayer();
        const isSpectating = !localPly.Alive() && IsValid(localPly.GetObserverTarget());
        if (isSpectating) {
            this.hudTarget = localPly.GetObserverTarget() as Player;
        } else {
            this.hudTarget = localPly;
        }
        this.teamColor = team.GetColor(this.hudTarget.Team());

        this.PaintTopBar()

        this.Paint()

    }

    public PaintTopBar(): void {
        const timeInSeconds = string.ToMinutesSeconds((GAMEMODE as GWGamemodeSH).Gamerules.GameTime);
        const label = (GAMEMODE as GWGamemodeSH).Gamerules.GameStateLabel
    }

}


hook.Add("HUDPaint", "GWHUD", () => GWHUD.GetInstance().Paint())
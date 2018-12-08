class GWHUD {
    private AbilityIcons: {[key: string]: IMaterial};

    constructor() {
        this.AbilityIcons = {};
        const icons = file.Find("materials/vgui/gw/abilityicons/*.png", "GAME")[0];
        icons.forEach(
            (iconFile: string) =>
                this.AbilityIcons[string.StripExtension(iconFile)] = new IMaterial("materials/vgui/gw/abilityicons/" + iconFile, "noclamp smooth"));
    }
}

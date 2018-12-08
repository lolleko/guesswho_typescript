class GWIconButton extends DButton {

    private color: Color;

    public SetColor(color: Color): void {
        this.color = color;
    }

    public SetIconSize(size: GWFontSize): void {
        this.SetFont("GWIcon" + size);
        this.SetSize(size, size);
    }

    public Init(): void {
        this.color = Color(0, 0, 0, 0);
        this.SetAllowNonAsciiCharacters(true);
        this.SetTextColor(Color(255, 255, 255));
        this.SetContentAlignment(5);
    }

    public Paint(width: number, height: number): boolean {
        draw.RoundedBox(width / 2, 0, 0, width, height, this.color);
        return false;
    }
}

vgui.Register("GWIconButton", GWIconButton, "DButton");

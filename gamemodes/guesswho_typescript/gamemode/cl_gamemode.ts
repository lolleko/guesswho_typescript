/** @extension GM */
class GWGamemodeCL extends GWGamemodeSH {

    private teamSelectScreen: GWTeamSelectScreen;

    public ShowTeam(): void {
        if ( IsValid(this.teamSelectScreen) ) {
            return;
        }

        this.teamSelectScreen = vgui.Create("GWTeamSelectScreen") as GWTeamSelectScreen;
    }

    public HideTeam(): void {
        if ( IsValid(this.teamSelectScreen) ) {
            this.teamSelectScreen.Remove();
        }
    }

    public IsBalancedToJoin(teamIndex: TEAM): boolean {
        if (LocalPlayer().Team() === teamIndex) {
            return true;
        }

        if (teamIndex === TEAM.SEEKER) {
            if (team.NumPlayers( TEAM.SEEKER ) > team.NumPlayers( TEAM.HIDER )
                || (LocalPlayer().Team() === TEAM.HIDER && team.NumPlayers( TEAM.SEEKER ) === team.NumPlayers( TEAM.HIDER ))) {
                return false;
            }
        } else if (teamIndex === TEAM.HIDER) {
            if (team.NumPlayers( TEAM.HIDER ) > team.NumPlayers( TEAM.SEEKER )
                || (LocalPlayer().Team() === TEAM.SEEKER && team.NumPlayers( TEAM.SEEKER ) === team.NumPlayers( TEAM.HIDER ))) {
                return false;
            }
        }
        return true;
    }
}

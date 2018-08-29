/** !MetaExtension */
class GWPlayer extends Player {
    public IsHider(): boolean {
        return this.Team() === TEAM.HIDER;
    }

    public IsSeeker(): boolean {
        return this.Team() === TEAM.SEEKER;
    }
}

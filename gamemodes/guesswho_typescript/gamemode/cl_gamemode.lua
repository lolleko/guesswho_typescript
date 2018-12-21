function GM.ShowTeam(self)
    if IsValid(self.teamSelectScreen) then
        return
    end
    self.teamSelectScreen = vgui.Create("GWTeamSelectScreen");
end
function GM.HideTeam(self)
    if IsValid(self.teamSelectScreen) then
        self.teamSelectScreen:Remove();
    end
end
function GM.IsBalancedToJoin(self,teamIndex)
    if LocalPlayer():Team()==teamIndex then
        return true
    end
    if teamIndex==SEEKER then
        if (team.NumPlayers(SEEKER)>team.NumPlayers(HIDER)) or ((LocalPlayer():Team()==HIDER) and (team.NumPlayers(SEEKER)==team.NumPlayers(HIDER))) then
            return false
        end
    elseif teamIndex==HIDER then
        if (team.NumPlayers(HIDER)>team.NumPlayers(SEEKER)) or ((LocalPlayer():Team()==SEEKER) and (team.NumPlayers(SEEKER)==team.NumPlayers(HIDER))) then
            return false
        end
    end
    return true
end

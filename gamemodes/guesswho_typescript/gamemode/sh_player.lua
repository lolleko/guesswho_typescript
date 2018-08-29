
-- Lua Library Imports
local __meta__Player = debug.getregistry()["Player"]
function __meta__Player.constructor(self)
end
function __meta__Player.IsHider(self)
    return self:Team()==HIDER
end
function __meta__Player.IsSeeker(self)
    return self:Team()==SEEKER
end
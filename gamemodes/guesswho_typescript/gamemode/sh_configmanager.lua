--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
-- Lua Library inline imports
__TS__Index = function(classProto)
    return function(tbl, key)
        local proto = classProto;
        while true do
            local val = rawget(proto, key);
            if val ~= nil then
                return val;
            end
            local getters = rawget(proto, "____getters");
            if getters then
                local getter = getters[key];
                if getter then
                    return getter(tbl);
                end
            end
            local base = rawget(rawget(proto, "constructor"), "____super");
            if not base then
                break;
            end
            proto = rawget(base, "prototype");
        end
    end;
end;

__TS__NewIndex = function(classProto)
    return function(tbl, key, val)
        local proto = classProto;
        while true do
            local setters = rawget(proto, "____setters");
            if setters then
                local setter = setters[key];
                if setter then
                    setter(tbl, val);
                    return;
                end
            end
            local base = rawget(rawget(proto, "constructor"), "____super");
            if not base then
                break;
            end
            proto = rawget(base, "prototype");
        end
        rawset(tbl, key, val);
    end;
end;

AddCSLuaFile();
local GWDefaultConfigData = {ActiveAbilities = {"weapon_gw_prophunt", "weapon_gw_surge", "weapon_gw_shockwave", "weapon_gw_cloak", "weapon_gw_shrink", "weapon_gw_decoy", "weapon_gw_sudoku", "weapon_gw_disguise", "weapon_gw_vampirism", "weapon_gw_ragdoll", "weapon_gw_superhot", "weapon_gw_dance_party", "weapon_gw_blasting_off", "weapon_gw_decoy2", "weapon_gw_teleport", "weapon_gw_deflect", "weapon_gw_timelapse", "weapon_gw_solarflare", "weapon_gw_mind_control", "weapon_gw_ant"}, AllAbilities = {"weapon_gw_prophunt", "weapon_gw_surge", "weapon_gw_shockwave", "weapon_gw_cloak", "weapon_gw_shrink", "weapon_gw_decoy", "weapon_gw_sudoku", "weapon_gw_disguise", "weapon_gw_vampirism", "weapon_gw_ragdoll", "weapon_gw_superhot", "weapon_gw_dance_party", "weapon_gw_blasting_off", "weapon_gw_decoy2", "weapon_gw_teleport", "weapon_gw_deflect", "weapon_gw_timelapse", "weapon_gw_solarflare", "weapon_gw_mind_control", "weapon_gw_ant"}, HiderModels = {"models/player/alyx.mdl", "models/player/breen.mdl", "models/player/barney.mdl", "models/player/eli.mdl", "models/player/gman_high.mdl", "models/player/kleiner.mdl", "models/player/monk.mdl", "models/player/odessa.mdl", "models/player/magnusson.mdl", "models/player/p2_chell.mdl", "models/player/mossman_arctic.mdl"}, SeekerModels = {"models/player/combine_super_soldier.mdl"}, TeamHidingColor = Color(138, 155, 15), TeamSeekingColor = Color(23, 89, 150), Version = "3.0.0", WalkerColors = {Color(61, 87, 105), Color(240, 240, 240), Color(50, 50, 50), Color(139, 115, 85), Color(241, 169, 101), Color(75, 97, 34), Color(157, 107, 0), Color(159, 205, 234), Color(94, 25, 34)}};
GWConfigManager = GWConfigManager or {};
GWConfigManager.__index = GWConfigManager;
GWConfigManager.prototype = GWConfigManager.prototype or {};
GWConfigManager.prototype.____getters = {};
GWConfigManager.prototype.__index = __TS__Index(GWConfigManager.prototype);
GWConfigManager.prototype.____setters = {};
GWConfigManager.prototype.__newindex = __TS__NewIndex(GWConfigManager.prototype);
GWConfigManager.prototype.constructor = GWConfigManager;
GWConfigManager.new = function(...)
    local self = setmetatable({}, GWConfigManager.prototype);
    self:____constructor(...);
    return self;
end;
GWConfigManager.prototype.____constructor = function(self)
end;
GWConfigManager.prototype.____getters.Data = function(self)
    return self.data;
end;
GWConfigManager.prototype.____setters.Data = function(self, data)
    self.data = data;
end;
GWConfigManager.GetInstance = function(self)
    if not GWConfigManager.instance then
        GWConfigManager.instance = GWConfigManager.new();
    end
    return GWConfigManager.instance;
end;
GWConfigManager.Setup = function(self)
    if SERVER then
        local instance = GWConfigManager:GetInstance();
        if instance:ExistsConfig() then
            instance:ReadConfig();
        else
            instance.data = GWDefaultConfigData;
            instance:WriteConfig();
        end
        hook.Add("PlayerInitialSpawn", "gw_config_manager_initial_spawn", function(ply)
            return instance:HandlePlayerInitialSpawn(ply);
        end);
    end
end;
GWConfigManager.prototype.WriteConfig = function(self)
    if not file.Exists("guesswho", "DATA") then
        file.CreateDir("guesswho");
    end
    file.Write("guesswho/config.txt", util.TableToJSON(self.data));
end;
GWConfigManager.prototype.ReadConfig = function(self)
    self.data = util.JSONToTable(file.Read("guesswho/config.txt"));
end;
GWConfigManager.prototype.ExistsConfig = function(self)
    return file.Exists("guesswho/config.txt", "DATA");
end;
GWConfigManager.prototype.SendConfig = function(self, ply)
    local filter = RecipientFilter();
    if ply then
        filter:AddPlayer(ply);
    else
        filter:AddAllPlayers();
    end
    net.Start(GWNetMessageName.SendConfig);
    net.WriteTable(self.data);
    net.Send(filter);
end;
GWConfigManager.prototype.HandlePlayerInitialSpawn = function(self, ply)
    self:SendConfig(ply);
end;
if SERVER then
    net.Receive(GWNetMessageName.RequestConfigUpdate, function(____, len, ply)
        if not ply:IsSuperAdmin() then
            return;
        end
        local newData = net.ReadTable();
        GWConfigManager:GetInstance().Data = newData;
        GWConfigManager:GetInstance():WriteConfig();
        GWConfigManager:GetInstance():SendConfig();
    end);
end
if CLIENT then
    net.Receive(GWNetMessageName.SendConfig, function(____, len, ply)
        local newData = net.ReadTable();
        GWConfigManager:GetInstance().Data = newData;
        team.SetColor(HIDER, newData.TeamHidingColor);
        team.SetColor(SEEKER, newData.TeamSeekingColor);
    end);
end

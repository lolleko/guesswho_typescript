--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
local ____TS_array = ({file.Find("gamemodes/guesswho/gamemode/cl_*", "GAME")})[0 + 1];
for ____TS_index = 1, #____TS_array do
    local csFile = ____TS_array[____TS_index];
    do
        AddCSLuaFile(csFile);
    end
    ::__continue1::
end
local ____TS_array = ({file.Find("gamemodes/guesswho/gamemode/sh_*", "GAME")})[0 + 1];
for ____TS_index = 1, #____TS_array do
    local shFile = ____TS_array[____TS_index];
    do
        AddCSLuaFile(shFile);
    end
    ::__continue2::
end
include("vgui/sv_include.lua");
include("sh_init.lua");

(table as any).unpack = unpack;

// Enums first
include("sh_classname.lua");
include("sh_netmessagename.lua");
include("sh_gamestate.lua");
include("sh_team.lua");

// Libs
include("ai/include.lua");
include("sh_player.lua");

// Logic
include("sh_configmanager.lua");
include("sh_gamemode.lua");

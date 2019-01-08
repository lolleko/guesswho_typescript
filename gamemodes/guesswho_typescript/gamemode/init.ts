// Clientside files
for (let csFile of file.Find( "gamemodes/guesswho/gamemode/cl_*", "GAME" )[0] as string[]) {
    AddCSLuaFile(csFile);
}
// Shared files
for (let shFile of file.Find( "gamemodes/guesswho/gamemode/sh_*", "GAME" )[0] as string[]) {
    AddCSLuaFile(shFile);
}

// Libs
include("vgui/sv_include.lua");

include("sh_init.lua");

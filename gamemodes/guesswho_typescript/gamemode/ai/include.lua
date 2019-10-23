--[[ Generated with https://github.com/Perryvw/TypescriptToLua ]]
AddCSLuaFile();
local files = {"behaviour_tree/behaviour_action.lua", "behaviour_tree/behaviour_condition.lua", "behaviour_tree/behaviour_parallel.lua", "behaviour_tree/behaviour_selector.lua", "behaviour_tree/behaviour_sequence.lua", "behaviour_tree/behaviour_status.lua", "behaviour_tree/behaviour_tree.lua", "behaviour_tree/behaviour_tree_builder.lua", "behaviour_tree/ibehaviour.lua", "behaviour_tree/ibehaviour_composite.lua", "finite_state_machine/finite_state_machine.lua", "finite_state_machine/finite_state_transition.lua"};
for ____TS_index = 1, #files do
    local file = files[____TS_index];
    do
        AddCSLuaFile(file);
        include(file);
    end
    ::__continue1::
end

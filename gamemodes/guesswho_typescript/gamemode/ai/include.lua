AddCSLuaFile();
local files = {"behaviour_tree/behaviour_action.lua","behaviour_tree/behaviour_condition.lua","behaviour_tree/behaviour_parallel.lua","behaviour_tree/behaviour_selector.lua","behaviour_tree/behaviour_sequence.lua","behaviour_tree/behaviour_status.lua","behaviour_tree/behaviour_tree.lua","behaviour_tree/behaviour_tree_builder.lua","behaviour_tree/ibehaviour.lua","behaviour_tree/ibehaviour_composite.lua","finite_state_machine/finite_state_machine.lua","finite_state_machine/finite_state_transition.lua"};
local __loopVariable0 = files;
for i0=1, #__loopVariable0 do
    local file = __loopVariable0[i0];
    do
        AddCSLuaFile(file);
        include(file);
    end
    ::__continue0::
end

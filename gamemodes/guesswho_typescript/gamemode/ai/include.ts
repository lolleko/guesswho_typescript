AddCSLuaFile();

const files = [
    "behaviour_tree/behaviour_action.lua",
    "behaviour_tree/behaviour_condition.lua",
    "behaviour_tree/behaviour_parallel.lua",
    "behaviour_tree/behaviour_selector.lua",
    "behaviour_tree/behaviour_sequence.lua",
    "behaviour_tree/behaviour_status.lua",
    "behaviour_tree/behaviour_tree.lua",
    "behaviour_tree/behaviour_tree_builder.lua",
    "behaviour_tree/ibehaviour.lua",
    "behaviour_tree/ibehaviour_composite.lua",

    "finite_state_machine/finite_state_machine.lua",
    "finite_state_machine/finite_state_transition.lua",
];

for (const file of files) {
    AddCSLuaFile(file);
    include(file);
}

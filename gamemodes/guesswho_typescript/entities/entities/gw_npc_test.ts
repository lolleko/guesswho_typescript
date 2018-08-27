import { BehaviourTreeBuilder } from "../../gamemode/ai/behaviour_tree/behaviour_tree_builder";
import { BehaviourStatus } from "../../gamemode/ai/behaviour_tree/behaviour_status";

AddCSLuaFile();

const eyeGlow = new IMaterial( "sprites/redglow1" )
const white = Color( 255, 255, 255, 255 )

/** !Extension ENT */
export class GWNPCTest extends NextBot {
    public Base: string = "base_nextbot";

    protected Initialize(): void {
        new BehaviourTreeBuilder<Entity>()
        .selector()
            .sequence()
            .action((ent) => BehaviourStatus.Success)
            .condition((ent) => ent.IsOnFire())
        .end();

    }
}
// based on
// http://www.gameaipro.com/GameAIPro/GameAIPro_Chapter06_The_Behavior_Tree_Starter_Kit.pdf

import {IBehaviour} from "./ibehaviour";
import {IBehaviourComposite} from "./ibehaviour_composite";

import {BehaviourStatus} from "./behaviour_status";

export class BehaviourTree<T> implements IBehaviour<T>
{
    private root?: IBehaviourComposite<T>;

    constructor(root?: IBehaviourComposite<T>)
    {
        this.root = root;
    }

    public setRoot(root: IBehaviourComposite<T>)
    {
        this.root = root;
    }

    public tick(state: T): BehaviourStatus
    {
        if (this.root)
        {
            return this.root.tick(state);
        }
        else
        {
            print("TICKING EMPTY BEHAVIOR TREE");
            return BehaviourStatus.Failure;
        }
    }
}

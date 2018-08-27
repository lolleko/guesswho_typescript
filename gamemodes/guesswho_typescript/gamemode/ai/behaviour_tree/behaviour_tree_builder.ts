import {IBehaviourComposite} from "./ibehaviour_composite";

import {BehaviourAction, BehaviourFunction} from "./behaviour_action";
import {BehaviourCondition, BehaviourConditionFunction} from "./behaviour_condition";
import {BehaviourSelector} from "./behaviour_selector";
import {BehaviourSequence} from "./behaviour_sequence";
import {BehaviourTree} from "./behaviour_tree";

export class BehaviourTreeBuilder<T>
{
    private parentStack: IBehaviourComposite<T>[];
    private result: BehaviourTree<T>;

    constructor()
    {
        this.parentStack = [];
        this.result = new BehaviourTree();
    }

    public action(func: BehaviourFunction<T>): BehaviourTreeBuilder<T>
    {
        assert(this.parentStackEmpty(),
                       "Can't create an unnested node. It must be a child node.");

        this.peekParent().addChild(new BehaviourAction(func));

        return this;
    }

    public condition(func: BehaviourConditionFunction<T>): BehaviourTreeBuilder<T>
    {
        assert(this.parentStackEmpty(),
                       "Can't create an unnested node. It must be a child node.");

        this.peekParent().addChild(new BehaviourCondition(func));

        return this;
    }

    public sequence(): BehaviourTreeBuilder<T>
    {
        this.pushParent(new BehaviourSequence<T>());
        return this;
    }

    public selector(): BehaviourTreeBuilder<T>
    {
        this.pushParent(new BehaviourSelector<T>());
        return this;
    }

    public finish(): BehaviourTreeBuilder<T>
    {
        this.popParent();
        return this;
    }

    public build(): BehaviourTree<T>
    {
        return this.result;
    }

    public pushParent(parent: IBehaviourComposite<T>)
    {
        // if this is our first parent attach to root
        if (this.parentStackEmpty())
        {
            this.result.setRoot(parent);
        }
        this.parentStack[this.parentStack.length] = parent;
    }

    public popParent()
    {
        const old = this.peekParent();
        delete this.parentStack[this.parentStack.length - 1];
        return old;
    }

    public peekParent(): IBehaviourComposite<T>
    {
        return this.parentStack[this.parentStack.length - 1];
    }

    public parentStackEmpty(): boolean
    {
        return this.parentStack.length === 0;
    }
}

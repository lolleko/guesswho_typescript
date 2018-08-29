class BehaviourTreeBuilder {
    private parentStack: IBehaviourComposite[];
    private result: BehaviourTree;

    constructor() {
        this.parentStack = [];
        this.result = new BehaviourTree();
    }

    public action(func: BehaviourFunction): BehaviourTreeBuilder {
        assert(!this.parentStackEmpty(),
               "Can't create this node without a parent (sequence/selector)");

        this.peekParent().addChild(new BehaviourAction(func));

        return this;
    }

    public condition(func: BehaviourConditionFunction): BehaviourTreeBuilder {
        assert(!this.parentStackEmpty(),
               "Can't create this node without a parent (sequence/selector)");

        this.peekParent().addChild(new BehaviourCondition(func));

        return this;
    }

    public sequence(): BehaviourTreeBuilder {
        this.pushParent(new BehaviourSequence());
        return this;
    }

    public selector(): BehaviourTreeBuilder {
        this.pushParent(new BehaviourSelector());
        return this;
    }

    public finish(): BehaviourTreeBuilder {
        this.popParent();
        return this;
    }

    public build(): BehaviourTree {
        return this.result;
    }

    public pushParent(parent: IBehaviourComposite): void {
        // if this is our first parent attach to root
        if (this.parentStackEmpty()) {
            this.result.setRoot(parent);
        }
        this.parentStack[this.parentStack.length] = parent;
    }

    public popParent(): IBehaviourComposite  {
        const old = this.peekParent();
        delete this.parentStack[this.parentStack.length - 1];
        return old;
    }

    public peekParent(): IBehaviourComposite {
        return this.parentStack[this.parentStack.length - 1];
    }

    public parentStackEmpty(): boolean {
        return this.parentStack.length === 0;
    }
}

class BehaviourSequence<T> implements IBehaviourComposite<T> {
    private children: Array<IBehaviour<T>>;
    private currentChildID: number;

    constructor() {
        this.children = [];
        this.currentChildID = 0;
    }

    public addChild(child: IBehaviour<T>) {
        this.children.push(child);
    }

    public tick(state: T): BehaviourStatus {
        while (true) {
            const currentChild = this.children[this.currentChildID];

            const status = currentChild.tick(state);

            if (status === BehaviourStatus.Failure) {
                this.currentChildID = 0;
                return status;
            } else if (status === BehaviourStatus.Running) {
                return status;
            }

            this.currentChildID++;

            if (this.currentChildID === this.children.length) {
                this.currentChildID = 0;
                return BehaviourStatus.Success;
            }
        }
    }
}

class BehaviourSelector implements IBehaviourComposite {
    private children: IBehaviour[];
    private currentChildID: number;

    constructor() {
        this.children = [];
        this.currentChildID = 0;
    }

    public addChild(child: IBehaviour): void {
        this.children.push(child);
    }

    public tick(): BehaviourStatus {
        const currentChild = this.children[this.currentChildID];
        while (true) {
            const status = currentChild.tick();

            if (status === BehaviourStatus.Success) {
                this.currentChildID = 0;
                return status;
            } else if (status === BehaviourStatus.Running) {
                return status;
            }

            this.currentChildID++;

            if (this.currentChildID === this.children.length) {
                this.currentChildID = 0;
                return BehaviourStatus.Failure;
            }
        }
    }
}

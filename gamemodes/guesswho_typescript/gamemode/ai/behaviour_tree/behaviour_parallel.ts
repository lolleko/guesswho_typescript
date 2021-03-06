class BehaviourParallel implements IBehaviourComposite {

    private children: IBehaviour[];

    private requiredToFail: number;
    private requiredToSucceed: number;

    constructor(requiredToFail: number = -1, requiredToSucceed: number = -1) {
        this.children = [];
        this.requiredToFail = requiredToFail;
        this.requiredToSucceed = requiredToSucceed;
    }

    public addChild(child: IBehaviour): void {
        this.children.push(child);
    }

    public tick(): BehaviourStatus {
        let successCounter = 0;
        let failCounter = 0;
        for (const child of this.children) {
            const result = child.tick();
            if (result === BehaviourStatus.Failure) {
                failCounter++;
                if (failCounter === this.requiredToFail) {
                    return BehaviourStatus.Failure;
                }
            }
            if (result === BehaviourStatus.Success) {
                successCounter++;
                if (failCounter === this.requiredToSucceed) {
                    return BehaviourStatus.Success;
                }
            }
        }
        if (this.requiredToFail === -1 && failCounter === this.children.length) {
            return BehaviourStatus.Failure;
        }
        if (this.requiredToSucceed === -1 && successCounter === this.children.length) {
            return BehaviourStatus.Success;
        }
        return BehaviourStatus.Running;
    }
}

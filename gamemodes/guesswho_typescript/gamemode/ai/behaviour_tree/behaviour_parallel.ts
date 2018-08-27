import {IBehaviour} from "./ibehaviour";
import {IBehaviourComposite} from "./ibehaviour_composite";

import {BehaviourStatus} from "./behaviour_status";

export class BehaviourParallel<T> implements IBehaviourComposite<T>
{
    private children: IBehaviour<T>[];

    private requiredToFail: number;
    private requiredToSucceed: number;

    constructor(requiredToFail: number = -1, requiredToSucceed: number = -1)
    {
        this.children = [];
        this.requiredToFail = requiredToFail;
        this.requiredToSucceed = requiredToSucceed;
    }

    public addChild(child: IBehaviour<T>)
    {
        this.children.push(child);
    }

    public tick(state: T): BehaviourStatus
    {
        let successCounter = 0;
        let failCounter = 0;
        for (const child of this.children) {
            const result = child.tick(state);
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

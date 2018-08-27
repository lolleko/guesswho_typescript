import {BehaviourStatus} from "./behaviour_status";

export interface IBehaviour<T> {
    tick(state: T): BehaviourStatus;
}

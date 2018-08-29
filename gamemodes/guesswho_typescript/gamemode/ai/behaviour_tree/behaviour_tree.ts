// based on
// http://www.gameaipro.com/GameAIPro/GameAIPro_Chapter06_The_Behavior_Tree_Starter_Kit.pdf
class BehaviourTree implements IBehaviour {

    private root?: IBehaviourComposite;

    constructor(root?: IBehaviourComposite) {
        this.root = root;
    }

    public setRoot(root: IBehaviourComposite): void {
        this.root = root;
    }

    public tick(): BehaviourStatus {
        if (this.root) {
            return this.root.tick();
        } else {
            print("TICKING EMPTY BEHAVIOR TREE");
            return BehaviourStatus.Failure;
        }
    }
}

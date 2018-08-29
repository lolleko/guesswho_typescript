AddCSLuaFile();

/** !Extension ENT */
class GWNPCTest extends NextBot {
    public Base: string = "base_nextbot";

    private behaviourTree: BehaviourTree;

    private currentPath: PathFollower;

    private hasPath: boolean;

    private targetPos: Vector;

    private loco: CLuaLocomotion;

    protected RunBehaviour(): void {
        this.behaviourTree = new BehaviourTreeBuilder()
            .sequence()
                .action(() => {
                    if (this.hasPath && this.currentPath.IsValid()) {
                        return BehaviourStatus.Success;
                    }

                    this.targetPos = VectorRand() as any * 200 + (this.GetPos() as any);
                    this.currentPath = Path("Follow");
                    this.currentPath.SetMinLookAheadDistance(300);
                    this.currentPath.SetGoalTolerance(20);
                    this.currentPath.Compute(this, this.targetPos);

                    if (!this.currentPath.IsValid()) {
                        return BehaviourStatus.Failure;
                    }

                    return BehaviourStatus.Success;
                })
                .action(() => {
                    // If the path is no longer valid we have reached our goal
                    if (!this.currentPath.IsValid()) {
                        return BehaviourStatus.Success;
                    }
                    this.currentPath.Update(this);

                    // Draw the path (only visible on listen servers or single player)
                    this.currentPath.Draw();

                    // If we're stuck then call the HandleStuck function and abandon
                    if (this.loco.IsStuck()) {
                        this.HandleStuck();
                    }

                    // If they set maxage on options then make sure the path is younger than it
                    if (this.currentPath.GetAge() > 10) {
                        return BehaviourStatus.Failure;
                    }

                    // If they set repath then rebuild the path every x seconds
                    // if ( options.repath ) then
                    //    if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
                    // end
                    return BehaviourStatus.Running;
                })
            .finish()
        .build();
        while (true) {
            this.behaviourTree.tick();
            coroutine.yield();
        }
    }
}

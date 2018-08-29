AddCSLuaFile();

const eyeGlow = new IMaterial("sprites/redglow1");
const white = Color(255, 255, 255, 255);

/** !Extension ENT */
class GWNPCWalker extends NextBot {

    public get LastAct(): ACT {
        return this.GetDTInt(0);
    }

    public set LastAct(act: ACT) {
        this.SetDTInt(0, act);
    }

    public get WalkerColorIndex(): number {
        return this.GetDTInt(1);
    }

    public set WalkerColorIndex(index: number) {
        this.SetDTInt(1, index);
    }

    public get WalkerModelIndex(): number {
        return this.GetDTInt(2);
    }

    public set WalkerModelIndex(index: number) {
        this.SetDTInt(2, index);
    }

    public get Locomotion(): CLuaLocomotion {
        return this.loco;
    }

    public Base: string = "base_nextbot";

    private walkerColor: Vector;

    private GetPlayerColor: () => Vector;

    private loco: CLuaLocomotion;

    private nextPossibleJump: number;

    private isJumping: boolean;

    private shouldCrouch: boolean;

    private isStuck: boolean;

    private isSitting: boolean;

    private sitUntil: number;

    private isDancing: boolean;

    private stuckTime: number;

    private stuckPos: Vector;

    private behaviourTree: BehaviourTree;

    private currentPath: PathFollower;
    private hasPath: boolean;
    private currentPathMaxAge: number;

    private targetPos: Vector;

    public Sit(duration: number = math.random(10, 30)): void {
        this.isSitting = true;
        this.sitUntil = CurTime() + duration;
    }

    protected SetupDataTables(): void {
        this.DTVar("Int", 0, "LastAct");
        this.DTVar("Int", 1, "WalkerColorIndex");
        this.DTVar("Int", 2, "WalkerModelIndex");
    }

    protected Initialize(): void {
        const models = GWConfigManager.GetInstance().Data.HiderModels;

        if (SERVER) {
            PrintTable(models);
            this.WalkerModelIndex = math.random(models.length) - 1;
        }

        this.SetModel(models[this.WalkerModelIndex]);

        const walkerColors = GWConfigManager.GetInstance().Data.WalkerColors;

        if (SERVER) {
            this.WalkerColorIndex = math.random(walkerColors.length) - 1;
        }

        const walkerClr = walkerColors[this.WalkerColorIndex];

        this.walkerColor = new Vector(walkerClr.r / 255, walkerClr.g / 255, walkerClr.b / 255);

        this.GetPlayerColor = () => this.walkerColor;

        this.SetHealth(100);

        if (SERVER) {
            this.SetCollisionBounds(new Vector(-8, -8, 0), new Vector(8, 8, 70));
            this.loco.SetStepHeight(21);
            this.loco.SetJumpHeight(68);
            this.nextPossibleJump = CurTime() + 5;
            this.isJumping = false;
            this.shouldCrouch = false;
        }
    }

    protected Draw(): void {
        this.DrawModel();
        let leftEye = this.GetAttachment(this.LookupAttachment("lefteye"));
        let rightEye = this.GetAttachment(this.LookupAttachment("righteye"));

        if (!leftEye) {
            leftEye = this.GetAttachment(this.LookupAttachment("left_eye"));
            rightEye = this.GetAttachment(this.LookupAttachment("right_eye"));
        }

        let leftEyePos: Vector | undefined;
        let rightEyePos: Vector | undefined;

        if (leftEye && rightEye) {
            leftEyePos = leftEye.Pos as any + this.GetForward();
            rightEyePos = rightEye.Pos as any + this.GetForward();
        } else {
            const eyes = this.GetAttachment(this.LookupAttachment("eyes"));
            if (eyes) {
                leftEyePos = (this.GetRight() as any) * -1.5 + (this.GetForward() as any) * 0.5 as any;
                rightEyePos = (this.GetRight() as any) * 1.5 + (this.GetForward() as any) * 0.5 as any;
            }
        }

        if (leftEyePos && rightEyePos) {
            render.SetMaterial(eyeGlow);
            render.DrawSprite(leftEyePos, 4, 4, white);
            render.DrawSprite(rightEyePos, 4, 4, white);
        }
    }

    protected Think(): boolean {
        if (SERVER) {
            const doors = ents.FindInSphere(this.GetPos(), 60);
            for (const door of doors) {
                const doorClass = door.GetClass();
                if (doorClass === "func_door"
                    || doorClass === "func_door_rotating"
                    || doorClass === "prop_door_rotating") {
                    door.Fire("Unlock", "", 0);
                    door.Fire("Open", "", 0.01);
                    door.SetCollisionGroup(COLLISION_GROUP.COLLISION_GROUP_DEBRIS);
                }
            }
            if (this.isStuck && CurTime() > this.stuckTime + 20 && this.stuckPos.DistToSqr(this.GetPos()) < 25) {
                const spawnPoints = (GAMEMODE as GWGamemode).Gamerules.SpawnPoints;
                const spawnPoint = spawnPoints[math.random(spawnPoints.length) - 1].GetPos();
                this.SetPos(spawnPoint);
                this.isStuck = false;
                MsgN(`Nextbot [${tostring(this.EntIndex())}][${this.GetClass()}]` +
                    "Got Stuck for over 20 seconds and will be repositioned, if this error gets spammed" +
                    "you might want to consider the following: Edit the navmesh or lower the walker amount.");
            }
            if (this.isStuck && this.stuckPos.DistToSqr(this.GetPos()) > 100) {
                this.isStuck = false;
            }
            if (this.GetSolidMask() === MASK.MASK_NPCSOLID_BRUSHONLY) {
                const entsInBox = ents.FindInBox(this.GetPos() as any + new Vector(-16, -16, 0),
                                                 this.GetPos() as any + new Vector(16, 16, 70));
                const occupied = entsInBox.some(ent => ent.GetClass() === "npc_walker" && ent !== this);
                if (!occupied) {
                    this.SetSolidMask(MASK.MASK_NPCSOLID);
                }
            }
        }
        return false;
    }

    protected RunBehaviour(): void {
        this.behaviourTree = new BehaviourTreeBuilder()
            .sequence()
            .action(() => {
                if (!this.isSitting) {
                    return BehaviourStatus.Success;
                }

                this.SetSequence("sit_zen");
                this.SetCollisionBounds(new Vector(-8, -8, 0), new Vector(8, 8, 36));

                if (this.sitUntil < CurTime()) {
                    this.SetCollisionBounds(new Vector(-8, -8, 0), new Vector(8, 8, 70));
                    this.isSitting = false;
                    return BehaviourStatus.Success;
                }

                return BehaviourStatus.Running;
            })
            .action(() => {
                if (this.hasPath && this.currentPath.IsValid()) {
                    return BehaviourStatus.Success;
                }

                this.loco.SetDesiredSpeed(100);
                const navs = navmesh.Find(this.GetPos(), 1000, 120, 120);
                const nav = navs[math.random(navs.length) - 1];

                if (!IsValid(nav)) {
                    return BehaviourStatus.Failure;
                }
                if (nav.IsUnderwater()) {
                    return BehaviourStatus.Failure;
                }
                this.targetPos = nav.GetRandomPoint();

                this.currentPath = Path("Follow");
                this.currentPath.SetMinLookAheadDistance(10);
                this.currentPath.SetGoalTolerance(10);
                this.currentPath.Compute(this, this.targetPos, this.PathGenerator());
                this.currentPathMaxAge = math.Clamp(this.currentPath.GetLength() / 90, 0.1, 15);

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
                const goal = this.currentPath.GetCurrentGoal();
                if (goal.type === 3) {
                    this.loco.JumpAcrossGap(goal.pos, goal.forward);
                } else if (goal.type === 2 && this.GetPos().Distance(goal.pos) < 30) {
                    this.isJumping = true;
                    this.loco.Jump();
                }

                this.currentPath.Update(this);

                this.currentPath.Draw();

                if (this.loco.IsStuck()) {
                    this.HandleStuck();
                }

                if (this.currentPath.GetAge() > this.currentPathMaxAge) {
                    return BehaviourStatus.Failure;
                }

                return BehaviourStatus.Running;
            })
            .finish()
            .build();
        while (true) {
            this.behaviourTree.tick();
            coroutine.yield();
        }
    }

    protected BodyUpdate(): void {
        const act = this.GetActivity();

        let idealAct = ACT.ACT_HL2MP_IDLE;

        // if act != this:GetLastAct() then act = this:GetLastAct() this:StartActivity(act) end

        const velocity = this.GetVelocity();

        const len2d = velocity.Length2D();

        if ( len2d > 150 ) {
            idealAct = ACT.ACT_HL2MP_RUN;
        } else if ( len2d > 10 ) {
            idealAct = ACT.ACT_HL2MP_WALK;
        }

        if (this.isJumping && this.WaterLevel() <= 0) {
            idealAct = ACT.ACT_HL2MP_JUMP_SLAM;
        }

        if (this.GetActivity() !== idealAct && !this.isSitting && !this.isDancing) {
            this.StartActivity(idealAct);
        }

        if (idealAct === ACT.ACT_HL2MP_RUN || idealAct === ACT.ACT_HL2MP_WALK) {

            this.BodyMoveXY();

        }

        this.FrameAdvance();
    }

    protected OnLandOnGround(ent: Entity): void {
        this.isJumping = false;
    }

    protected OnLeaveGround(ent: Entity): void {
        this.isJumping = true;
    }

    protected OnContact(ent: Entity): void {
        if (ent.GetClass() === this.GetClass() || ent.IsPlayer()) {
            const calcDogeGoal = (collider: Entity) => {
                const dogeDirection = new Vector(collider.GetPos());
                dogeDirection.Add(collider.GetRight() as any * 30 as any);
                dogeDirection.Add(collider.GetForward() as any * 30 as any);
                return dogeDirection;
            };

            this.loco.Approach(calcDogeGoal(this), 1000);

            if (math.abs(this.GetPos().z - ent.GetPos().z) > 30) {
                this.SetSolidMask( MASK.MASK_NPCSOLID_BRUSHONLY );
            }
        }
        if  (ent.GetClass() === "prop_physics_multiplayer"
             || ent.GetClass() === "prop_physics"
             && !GetConVar("gw_propfreeze_enabled").GetBool()) {
            // this.loco:Approach( this:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 2000,1000)
            const phys = ent.GetPhysicsObject();
            if (!IsValid(phys)) {
                return;
            }
            // @ts-ignore
            phys.ApplyForceCenter(this.GetPos() - ent.GetPos() * 1.2 );
            DropEntityIfHeld( ent );
        }
        if (ent.GetClass() === "func_breakable" || ent.GetClass() === "func_breakable_surf") {
            ent.Fire("Shatter");
        }
    }

    protected OnStuck(): void {
        // debugoverlay.Cross( self:GetPos() + Vector(0,0,70), 10, 20, Color(0,255,255), true )
        if (!this.isStuck) {
            this.stuckTime = CurTime();
        }
        this.stuckPos = this.GetPos();
    }
    protected OnUnStuck(): void {
        if (this.stuckPos.Distance(this.GetPos()) > 10 || this.isSitting) {
            this.isStuck = false;
        }
    }

    protected Use(activator: Entity, caller: Entity, useType: USE, value: number): void {
        if ((caller as GWPlayer).IsHider() && GetConVar( "gw_changemodel_hiding" ).GetBool()) {
            this.SetModel(this.GetModel());
        }
    }

    private PathGenerator(): (area: CNavArea, fromArea: CNavArea, ladder: CNavLadder, elevator: any, length: number) => number {
        return (area: CNavArea, fromArea: CNavArea, ladder: CNavLadder, elevator: any, length: number) => {
            if (!IsValid(fromArea)) {
                // first area in path, no cost
                return 0;
            }

            if (!this.loco.IsAreaTraversable(area)) {
                // our locomotor says we can't move here
                return -1;
            }

            // compute distance traveled along path so far
            let dist = 0;

            if ( IsValid( ladder ) ) {
                dist = ladder.GetLength();
            } else if ( length > 0 ) {
                // optimization to avoid recomputing length
                dist = length;
            } else {
                dist = area.GetCenter().Distance(fromArea.GetCenter());
            }

            let cost = dist + fromArea.GetCostSoFar();

            // check height change
            const deltaZ = fromArea.ComputeAdjacentConnectionHeightChange(area);
            if (deltaZ >= this.loco.GetStepHeight()) {
                if ( deltaZ >= this.loco.GetMaxJumpHeight() - 20) {
                    return -1;
                }
                cost = cost + deltaZ;
            } else if ( deltaZ < -this.loco.GetDeathDropHeight()) {
                // too far to drop
                return -1;
            }

            return cost;
        };
    }
}

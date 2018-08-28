AddCSLuaFile();

const eyeGlow = new IMaterial( "sprites/redglow1" );
const white = Color( 255, 255, 255, 255 );

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
    public Base: string = "base_nextbot";

    private walkerColor: Vector;

    private GetPlayerColor: () => Vector;

    private loco: CLuaLocomotion;

    private nextPossibleJump: number;

    private isJumping: boolean;

    private shouldCrouch: boolean;

    private isStuck: boolean;

    private isSitting: boolean;

    private stuckTime: number;

    private stuckPos: Vector;

    public MoveSomeWhere(distance: number = 1000): void {
        this.loco.SetDesiredSpeed( 100 );
        const navs = navmesh.Find(this.GetPos(), distance, 120, 120);
        const nav = navs[math.random(navs.length) - 1];

        if (!IsValid(nav)) {
            return;
        }
        if (nav.IsUnderwater()) {
            return;
        }
        const pos = nav.GetRandomPoint();
        const maxAge = math.Clamp(pos.Distance(this.GetPos()) / 120, 0.1, 10);
        this.MoveToPos( pos, { tolerance: 30, maxage: maxAge, lookahead: 10, repath: 2 });
    }

    public MoveToSpot(type: string): void {
        const pos = this.FindSpot( "random", { type, radius: 5000 } );
        if ( pos ) {
            const nav = navmesh.GetNavArea(pos, 20);
            if (!IsValid(nav)) {
                return;
            }
            if (!nav.IsUnderwater()) {
                this.loco.SetDesiredSpeed( 200 );
                this.MoveToPos( pos, { tolerance: 30, lookahead: 10, repath: 2 } );
            }
        }
    }

    public Sit(): void {
        // self:PlaySequenceAndWait( "idle_to_sit_ground" ) //broken for clients so removed
        this.SetSequence( "sit_zen" );
        this.isSitting = true;
        this.SetCollisionBounds( new Vector(-8, -8, 0), new Vector(8, 8, 36) );
        coroutine.wait( math.Rand(10, 60) );
        this.SetCollisionBounds( new Vector(-8, -8, 0), new Vector(8, 8, 70) );
        this.isSitting = false;
        // self:PlaySequenceAndWait( "sit_ground_to_idle" )
        // coroutine.wait( math.Rand(0,1.5) )
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
            this.SetCollisionBounds(new Vector(-16, -16, 0), new Vector(16, 16, 70));
            this.loco.SetStepHeight(22);
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
                    || doorClass === "func_door_rotating"
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
            if (!this.isJumping && this.GetSolidMask() === MASK.MASK_NPCSOLID_BRUSHONLY) {
                const entsInBox = ents.FindInBox(this.GetPos() as any + new Vector( -16, -16, 0 ),
                                                 this.GetPos() as any + new Vector( 16, 16, 70 ));
                const occupied = entsInBox.some(ent => ent.GetClass() === "npc_walker" && ent !== this);
                if (!occupied) {
                    this.SetSolidMask(MASK.MASK_NPCSOLID);
                }
            }
        }
        return false;
    }

    protected RunBehaviour(): void {
        while (true) {
            // Scatter them after spawn
            this.MoveSomeWhere(10000);
            while ( true ) {
                const rand = math.random(1, 100);
                if (rand > 0 && rand < 10) {
                    this.MoveToSpot( "hiding" );
                    coroutine.wait(math.random(1, 10));
                } else if (rand > 10 && rand < 15) {
                    this.Sit();
                    coroutine.wait(1);
                } else {
                    this.MoveSomeWhere();
                    coroutine.wait(1);
                }
            }
        }
    }

}

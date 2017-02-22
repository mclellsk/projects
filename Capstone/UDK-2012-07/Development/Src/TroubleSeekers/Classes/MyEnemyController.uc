class MyEnemyController extends UTBot;

//================================================================================================================================================
// BEGIN VARIABLES
//================================================================================================================================================

var string GoalString;            // for debugging - used to show what bot is thinking (with 'ShowDebug')
var    bool bJustLanded;

var float fLastHeardTime;
var Actor LastHeardActor;

var float fLastSeenTime;
var Pawn LastSeenPawn;

var vector TempDest;

var Actor Destination;
var Actor Target;

//================================================================================================================================================
// END VARIABLES
//================================================================================================================================================

//================================================================================================================================================
// START DEBUG DISPLAY
//================================================================================================================================================

simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
    local array<string> T;
    local Canvas Canvas;
    local int i;
    local float XL, YL, CurYL, BestXL;

    Super.DisplayDebug(HUD, out_YL, out_YPos);
    
    Canvas = HUD.Canvas;

    if (HUD.ShouldDisplayDebug('ai'))
    {
        T[T.Length] = "** GOAL **";
        T[T.Length] = "GoalString:" @ GoalString;
        T[T.Length] = " ";
        T[T.Length] = "** HEARD **";
        T[T.Length] = "Last Time:" @ fLastHeardTime;
        T[T.Length] = "Last Actor:" @ LastHeardActor;
        T[T.Length] = "** SEEN **";
        T[T.Length] = "Last Time:" @ fLastSeenTime;
        T[T.Length] = "Last Pawn:" @ LastSeenPawn;
    }
    
    for (i = 0; i < T.length; i++)
    {
        Canvas.TextSize(T[i], XL, YL);
        CurYL += YL;
        if (XL > BestXL)
            BestXL = XL;
    }

    Canvas.SetPos(2, out_YPos - 2);
    Canvas.SetDrawColor(0, 0, 0, 150);
    Canvas.DrawRect(BestXL + 2, CurYL + 2);
    Canvas.SetPos(4, out_YPos);

    Canvas.SetDrawColor(255, 255, 255);
    for (i = 0; i < T.length; i++)
    {
        Canvas.DrawText(T[i]);
        out_YPos += out_YL;
        Canvas.SetPos(4, out_YPos);
    }
}

//================================================================================================================================================
// END DEBUG DISPLAY
//================================================================================================================================================

function Possess(Pawn aPawn, bool bVehicleTransition)
{
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "DecisionComponent:" @ DecisionComponent);
    if (aPawn.bDeleteMe)
    {
        `Warn(self @ GetHumanReadableName() @ "attempted to possess destroyed Pawn" @ aPawn);
        ScriptTrace();
        GotoState('Dead');
    }
    else
    {
        Super.Possess(aPawn, bVehicleTransition);
        Pawn.SetMovementPhysics();
        if (Pawn.Physics == PHYS_Walking)
            Pawn.SetPhysics(PHYS_Falling);
    }

    WhatToDoNext();
}

/*
HearNoise
    Counterpart to the Actor::MakeNoise() function, called whenever this player is within range of a given noise.
    Used as AI audio cues, instead of processing actual sounds.
*/
event HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
    fLastHeardTime = WorldInfo.TimeSeconds;
    LastHeardActor = NoiseMaker;
}

/*
SeePlayer
    Called whenever Seen is within of our line of sight    if Seen.bIsPlayer==true.
*/
event SeePlayer(Pawn Seen)
{
    fLastSeenTime = WorldInfo.TimeSeconds;
    LastSeenPawn = Seen;
    
    // Only chase humans for now
    if ((Enemy == None) && Seen.IsHumanControlled())
    {
        Enemy = Seen;
        `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "Enemy:" @ Enemy);
        WhatToDoNext();
    }
    
    if (Enemy == Seen)
    {
        VisibleEnemy = Enemy;
        EnemyVisibilityTime = WorldInfo.TimeSeconds;
        bEnemyIsVisible = true;
    }
}

/** triggers ExecuteWhatToDoNext() to occur during the next tick
 * this is also where logic that is unsafe to do during the physics tick should be added
 * @note: in state code, you probably want LatentWhatToDoNext() so the state is paused while waiting for ExecuteWhatToDoNext() to be called
 */
event WhatToDoNext()
{
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName());
    Super.WhatToDoNext();
    
    if (bExecutingWhatToDoNext)
    {
        `Log("WhatToDoNext loop:" @ GetHumanReadableName());
        // ScriptTrace();
    }

    if (Pawn == None)
    {
        `Warn(GetHumanReadableName() @ "WhatToDoNext with no pawn");
        return;
    }
    
    DecisionComponent.bTriggered = true;
}


/*
ExecuteWhatToDoNext
    Entry point for AI decision making
    This gets executed during the physics tick so actions that could change the physics state (e.g. firing weapons) are not allowed
*/
protected event ExecuteWhatToDoNext()
{
    // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName());

    // pawn got destroyed between WhatToDoNext() and now - abort
    if (Pawn == None)
        return;

    GoalString = "WhatToDoNext at "$WorldInfo.TimeSeconds;

    if (Pawn.Physics == PHYS_None)
        Pawn.SetMovementPhysics();

    if ((Pawn.Physics == PHYS_Falling) && DoWaitForLanding())
        return;
        
    if ((Enemy != None) && ((Enemy.Health <= 0) || (Enemy.Controller == None)))
        Enemy = None;

    if (Enemy != None)
    {
		if (CanAttack(Enemy))
		{
			GotoState('Attack');
		}
		else
		{
			GoalString @= "- Follow " @ Enemy;
			GotoState('Follow');
		}
        return;
    }
        
    GoalString @= "- Wander or Camp at" @ WorldInfo.TimeSeconds;
    WanderOrCamp();
}

/*
DoWaitForLanding
    Called from ExecuteWhatToDoNext when falling.
    Overridden in other states as needed.
*/
function bool DoWaitForLanding()
{
    GotoState('WaitingForLanding');
    return true;
}

/*
WaitingForLanding
    State set by DoWaitForLanding().
*/
State WaitingForLanding
{
    function bool DoWaitForLanding()
    {
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "bJustLanded:" @ bJustLanded);
        
        if (bJustLanded)
            return false;

        BeginState(GetStateName());
        return true;
    }

    event bool NotifyLanded(vector HitNormal, Actor FloorActor)
    {
        bJustLanded = true;
        Global.NotifyLanded(HitNormal, FloorActor);
        // `log(GetEnum(enum'ENetMode', WorldInfo.NetMode) @ self @ GetFuncName() @ "bJustLanded:" @ bJustLanded);
        return false;
    }

    function Timer()
    {
    }

    function BeginState(Name PreviousStateName)
    {
        bJustLanded = false;
    }

Begin:
    if (Pawn.PhysicsVolume.bWaterVolume || (Pawn.Physics == PHYS_Swimming))
        LatentWhatToDoNext();

    if (Pawn.GetGravityZ() > 0.9 * WorldInfo.DefaultGravityZ)
    {
         if ((MoveTarget == None) || (MoveTarget.Location.Z > Pawn.Location.Z))
        {
            NotifyMissedJump();
            if (MoveTarget != None)
                MoveToward(MoveTarget,Focus,,true);
        }
        else if (Pawn.Physics != PHYS_Falling)
            LatentWhatToDoNext();
        else
        {
            Sleep(0.5);
            Goto('Begin');
        }
    }

    GoalString = "Waiting for us to land...";
    WaitForLanding();
    LatentWhatToDoNext();
    Sleep(0.5);
    Goto('Begin');
}

/*
WanderOrCamp
    With nothing better to do, wander around.
*/
function WanderOrCamp()
{
    GotoState('Wander', 'Begin');
}

simulated function bool TraceLoc(out vector out_Loc, out vector out_Normal)
{
    local vector HitLocation, HitNormal, TraceStart, TraceEnd;
    local actor HitActor;
    
    if (Pawn == None)
        return false;
    
    TraceStart = out_Loc;
    TraceStart.Z += (Pawn.GetCollisionHeight() * 2);
    TraceEnd = out_Loc;
    TraceEnd.Z -= (Pawn.GetCollisionHeight() * 2);
    
    ForEach TraceActors(class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart)
    {
        // Block if we've hit world geometry
        if (HitActor.bWorldGeometry || HitActor.IsA('InterpActor'))
        {
            out_Loc = HitLocation;
            out_Normal = HitNormal;
            return true;
            break;
        }
    }
    
    return false;
}

/*
WaitingForLanding
    State set by DoWaitForLanding().
*/
State Wander
{
	Begin:
		if(Destination == none || Pawn.ReachedDestination(Destination))
		{
			Destination = FindRandomDest();
			`log("destination Set");
		}

		//Find a path to the destination and move to the next node in the path
		MoveTarget = FindPathToward(Destination);
		if(MoveTarget != None) 
		{
			`log("Target Found");
			MoveToward(MoveTarget);
	  
		}
   
		sleep(0.5);
		GoToState('Wander');
}


state Follow
{
Begin:
	MoveToward(Enemy, Enemy, 128);
	LatentWhatToDoNext();
}

state Attack
{
Begin:
	`log("================ATTACK===================");
	FireWeaponAt(Enemy);
	LatentWhatToDoNext();
}

defaultproperties
{
    bIsPlayer=false
}
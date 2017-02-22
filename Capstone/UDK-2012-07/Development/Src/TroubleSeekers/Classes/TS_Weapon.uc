//
// TS_Weapon
// Base class for handling melee weapons
// Different melee weapons are meant to extend this class and have their attributes defined in their defaultproperties
//
// Extends from UTWeapon
//

class TS_Weapon extends UTWeapon;

var array<int> Swings;

//Maximum number of swings handled by the sword (Effectively ammo for the sword)
var const int MaxSwings;

//Array of targets hit by weapon
var array<Actor> SwingHitActors;

//StartSocket and Endsocket are used to determine what part of the weapon hits an enemy
var name StartSocket, EndSocket;


//Function: ClientGivenTo(Pawn NewOwner, bool bDoNotActivate)
//Description: This function parents the weapon to the model of the pawn that obtains it in game
// pawn NewOwner - Object that acquires the item
//bool bDoNotActivate - If true, doesn't activate the item when it's picked up
reliable client function ClientGivenTo(Pawn NewOwner, bool bDoNotActivate) //TODO: Convert this function from MyPawn to TS_Pawn
{
    local TS_Pawn holderPawn;

    super.ClientGivenTo(NewOwner, bDoNotActivate);

    holderPawn = TS_Pawn(NewOwner);

    if (holderPawn != none && holderPawn.Mesh.GetSocketByName(holderPawn.SwordHandSocketName) != none) //Attach weapon to pawn's weapon socket
    {
        Mesh.SetShadowParent(holderPawn.Mesh);
        Mesh.SetLightEnvironment(holderPawn.LightEnvironment);
        holderPawn.Mesh.AttachComponentToSocket(Mesh, holderPawn.SwordHandSocketName);
   }
}

//Function: RestoreAmmo(int Amount, optional byte FireModeNum)
//int Amount - Sets ammo count to this value if it doesn't exceed MaxSwings
function RestoreAmmo(int Amount, optional byte FireModeNum)
{
   Swings[FireModeNum] = Min(Amount, MaxSwings);
}

//Function: ConsumeAmmo(byte FireModeNum)
//byte FireModeNum - Identifier signaling what type of fire mode was activated (left click attack/right click attack)
function ConsumeAmmo(byte FireModeNum)
{
   if (HasAmmo(FireModeNum))
   {
        if(Swings[FireModeNum] > 1) Swings[FireModeNum]--;
   }
}

//Simulated Function: HasAmmo(byte FireModeNum, optional int Amount)
//byte FireModeNum - Identifier signaling what type of fire mode was activated (left click attack/right click attack)
//optional int Amount - Tests the ammo (number of swings left, in this case) remaining in the weapon against this value
simulated function bool HasAmmo(byte FireModeNum, optional int Amount)
{
   return Swings[FireModeNum] > Amount;
}

//Simulated Function: FireAmmunition() 
//Description: Called automatically when a weapon is fired
simulated function FireAmmunition()
{
   StopFire(CurrentFireMode);
   SwingHitActors.Remove(0, SwingHitActors.Length);

   if (HasAmmo(CurrentFireMode))
   {
      super.FireAmmunition(); //Proceed through the rest of UTWeapon's firing sequence
      /*if(CurrentFireMode == 0)*/ TS_Pawn(Owner).SwingAnim.PlayCustomAnim('Attack_Sword_0', 1.5); //Tell pawn to perform attack animation
      //else if(CurrentFireMode == 1) TS_Pawn(Owner).SwingAnim.PlayCustomAnim('Attack_Sword_1', 1.5);
   }
   
    /*if (MaxSwings - Swings[0] == 0) //Debug code playing animations based on amount of swings remaining
    {
        MyPawn(Owner).SwingAnim.PlayCustomAnim('Human_Attack', 1.0);
    }
    else
    {
        MyPawn(Owner).SwingAnim.PlayCustomAnim('Human_Attack', 1.0);
    }*/
}

//Simulated State: Swinging
//Description: Called automatically similar to FireAmmunition, with the difference being that swinging/weaponfiring is a boolean state rather than a function
simulated state Swinging extends WeaponFiring
{
   simulated event Tick(float DeltaTime) //while Swinging is true, traceswing will be called once per game tick
   {
      super.Tick(DeltaTime); //DeltaTime is the time between ticks
      TraceSwing();
   }

   simulated event EndState(Name NextStateName) //EndState will be called automatically and advance the system to the next state
   {
      super.EndState(NextStateName);
      SetTimer(GetFireInterval(CurrentFireMode), false, nameof(ResetSwings));
   }
}

//Function: ResetSwings()
function ResetSwings()
{
   RestoreAmmo(MaxSwings);
}

//Function: GetSwordSocketLocation(Name SocketName)
//Name SocketName - The location of the socket on the weapon with this name is identified and returned (as a vector) for use in the TraceSwing function
function Vector GetSwordSocketLocation(Name SocketName)
{
   local Vector SocketLocation;
   local Rotator SwordRotation;
   local SkeletalMeshComponent SMC;

   SMC = SkeletalMeshComponent(Mesh);

   if (SMC != none && SMC.GetSocketByName(SocketName) != none)
   {
      SMC.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SwordRotation);
   }

   return SocketLocation;
}

//Function: AddToSwingHitActors(Actor HitActor)
//Actor HitActor - The actor that was hit with the weapon - They're added to an array and a bool is returned that determines if the process was successful
function bool AddToSwingHitActors(Actor HitActor)
{
   local int i;

   for (i = 0; i < SwingHitActors.Length; i++)
   {
      if (SwingHitActors[i] == HitActor)
      {
         return false;
      }
   }

   SwingHitActors.AddItem(HitActor);
   return true;
}

//Function TraceSwing()
//Description: Determines what part of the weapon will physically hit an enemy
function TraceSwing()
{
   local Actor HitActor;
   local Vector HitLoc, HitNorm, SwordTip, SwordHilt, Momentum;
   local int DamageAmount;

   SwordTip = GetSwordSocketLocation(EndSocket);
   SwordHilt = GetSwordSocketLocation(StartSocket);
   DamageAmount = FCeil(InstantHitDamage[CurrentFireMode]);

   foreach TraceActors(class'Actor', HitActor, HitLoc, HitNorm, SwordTip, SwordHilt)
   {
      if (HitActor != self && AddToSwingHitActors(HitActor))
      {
         Momentum = Normal(SwordTip - SwordHilt) * InstantHitMomentum[CurrentFireMode];
         HitActor.TakeDamage(DamageAmount, Instigator.Controller, HitLoc, Momentum, class'DamageType');
      }
   }
}


DefaultProperties
{
    //CrosshairImage=Copy texture from Content Browser
    CrossHairCoordinates=(U=384,V=0,UL=64,VL=64)
}
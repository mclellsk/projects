class MyPlayerController extends UTPlayerController;

var SkeletalMesh defaultMesh;
var MaterialInterface defaultMaterial0;
var MaterialInterface defaultMaterial1;
var AnimTree defaultAnimTree;
var array<AnimSet> defaultAnimSet;
var AnimNodeSequence defaultAnimSeq;
var PhysicsAsset defaultPhysicsAsset;

/* State:
 * PlayerWalking
 * Description:
 * This state controls the behaviour of the player's movement while in the walking state.
 * Currently allows the player to move independant of rotation.
 */
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;

   function ProcessMove(float DeltaTime, vector NewAccel, eDoubleClickDir DoubleClickMove, rotator DeltaRot)
   {	
		local Vector tempAccel, tempVec1, tempVec2;
		
		if( Pawn == None )
		{
			return;
		}

		if (Role == ROLE_Authority)
		{
			Pawn.SetRemoteViewPitch( Rotation.Pitch );
		}
		
		//This section switches the movement to not be based on direction of rotation
		/*
		//The 'move forward' vector in world coordinate
		tempVec1=vect(1,0,0) >> Pawn.GetViewRotation(); 
		//The 'move left' vector in world coordinate
		tempVec2=vect(0,1,0) >> Pawn.GetViewRotation();
		//make 'move forward' ->  'move north' and 'move left' ->  'move east'
		tempAccel=(NewAccel dot tempVec1)*vect(1,0,0)+(NewAccel dot tempVec2)*vect(0,1,0);
		Pawn.Acceleration = tempAccel;
		*/

		CheckJumpOrDuck();
		super.ProcessMove(DeltaTime, NewAccel, DoubleClickMove, DeltaRot);
   }
}

/* Function:
 * UpdateRotation(float DeltaTime)
 * Description:
 * This function controls the way player rotation is handled.
 * Currently allows the player to turn based on mouse movement in the x-direction.
 */
function UpdateRotation(float DeltaTime)
{
   local Rotator   DeltaRot, newRotation, ViewRotation;

   ViewRotation = Rotation;
   if (Pawn!=none)
   {
      Pawn.SetDesiredRotation(ViewRotation);
   }

   // Calculate Delta to be applied on ViewRotation

   //TODO: Fix rotation of player to follow the cursor position
   DeltaRot.Pitch = 0;

   if (MouseInterfacePlayerInput(PlayerInput).MousePosition.Y > 720/2)
		DeltaRot.Yaw = 65536/2 - PlayerInput.aTurn;
   else
		DeltaRot.Yaw = PlayerInput.aTurn;

   ProcessViewRotation( DeltaTime, ViewRotation, DeltaRot );
   SetRotation(ViewRotation);
   NewRotation = ViewRotation;
   NewRotation.Roll = Rotation.Roll;

   if ( Pawn != None )
      Pawn.FaceRotation(NewRotation, deltatime);
}   

/* Function:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned. Resets the player mesh to the resources specified in the DefaultProperties.
 */
simulated function PostBeginPlay() {
	super.PostBeginPlay();
	ResetMesh();
}

/* Function:
 * ResetMesh()
 * Description:
 * Resets the player mesh.
 */
public function ResetMesh()
{
	self.Pawn.Mesh.SetSkeletalMesh(defaultMesh);
	self.Pawn.Mesh.SetMaterial(0,defaultMaterial0);
	self.Pawn.Mesh.SetMaterial(1,defaultMaterial1);
	self.Pawn.Mesh.SetPhysicsAsset(defaultPhysicsAsset );
	self.Pawn.Mesh.AnimSets=defaultAnimSet;
	self.Pawn.Mesh.SetAnimTreeTemplate(defaultAnimTree );
}

/* Event:
 * Possess(Pawn inPawn, bool bVehicleTransition)
 * Description:
 * Gives player control of pawn.
 */
event Possess(Pawn inPawn, bool bVehicleTransition)
{
	Super.Possess(inPawn, bVehicleTransition);
	//SetBehindView(true);	
}

defaultproperties
{
	InputClass=class'MouseInterfacePlayerInput'

	defaultMesh=SkeletalMesh'UPK_Characters.Armature'
	defaultMaterial0=Material'UPK_Characters.Human_Main_01_Mat'
	defaultMaterial1=Material'UPK_Characters.Human_Main_01_Mat'
	defaultAnimTree=AnimTree'UPK_Characters.TS_HumanAnimTree'
	defaultAnimSet(0)=AnimSet'UPK_Characters.HumanAnimSet'
	defaultPhysicsAsset=PhysicsAsset'UPK_Characters.Armature_Physics'
	Name="Default__MyPlayerController"
}
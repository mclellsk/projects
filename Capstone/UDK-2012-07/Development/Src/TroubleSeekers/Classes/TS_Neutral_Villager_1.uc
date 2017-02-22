class TS_Neutral_Villager_1 extends TS_Pawn;

var(NPC) SkeletalMeshComponent NPCMesh;
var(NPC) class<AIController> NPCController;

//Physical Representation of Item to Drop
var TS_WorldItemPickup DropItem;
//Item Properties of the Item to Drop
var TS_Items AddItem;

/* Event:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned. Sets the NPCController to become the controller class
 * for this NPC.
 */
simulated event PostBeginPlay()
{
	if(NPCController != none)
	{
		ControllerClass = NPCController;
	}
	Super.PostBeginPlay();

	//Name of the NPC
	PawnName = "Billy The Old";

	InitializeConversations();
}

function InitializeConversations()
{
	ConversationIndex = 0;

	//Conversation 1
	Conversations.AddItem(0);
	//Conversation 2
	Conversations.AddItem(1);
}

/* State:
 * Dying
 * Description:
 * State entered by the NPC when damage is taken.
 */
state Dying
{
	event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
	{
		if ( (Physics == PHYS_None) && (Momentum.Z < 0) )
			Momentum.Z *= -1;

		Velocity += 3 * momentum/(Mass + 200);

		if ( damagetype == None )
		{
			DamageType = class'DamageType';
		}

		Health -= Damage;
	}
}

/* Function:
 * bool Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
 * Description:
 * This function controls the state/behaviour of the NPC when it has 0 health. Specifically
 * placing the NPC into a ragdoll mode (going limp).
 * Ragdoll Code By: Wizzard~Of~Oz
 * Source: http://forums.epicgames.com/threads/732162-setting-up-ragdolls-for-death
 */
simulated function bool Died(Controller Killer, class<DamageType> damageType, Vector HitLocation)
{
	local vector ApplyImpulse, ShotDir;

	bReplicateMovement = false;
	bTearOff = true;
	Velocity += TearOffMomentum;
	SetDyingPhysics();
	bPlayedDeath = true;
	HitDamageType = DamageType;
	TakeHitLocation = HitLocation;

	//Add kill increment to the player's event manager
	MyPawn(Killer.Pawn).TSEventManager.AddKill(class'TS_Neutral_Villager_1');

	//TODO: Fix code to apply upward kick forces to ragdoll upon death.
	if (Super.Died(Killer, damageType, HitLocation))
	{
		Mesh.MinDistFactorForKinematicUpdate = 0.f;
		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(FALSE);
		SetPawnRBChannels(TRUE);
		Mesh.SetRBChannel(RBCC_Pawn);
		Mesh.SetRBCollidesWithChannel(RBCC_Default, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Pawn, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Vehicle, true);
		Mesh.SetRBCollidesWithChannel(RBCC_Untitled3, false);
		Mesh.SetRBCollidesWithChannel(RBCC_BlockingVolume, true);
		Mesh.ForceSkelUpdate();
		Mesh.SetTickGroup(TG_PostAsyncWork);
		PreRagdollCollisionComponent = CollisionComponent;
		CollisionComponent = Mesh;
		CylinderComponent.SetActorCollision(false, false);
		Mesh.SetActorCollision(true, false);
		Mesh.SetTraceBlocking(true, true);
		SetPhysics(PHYS_RigidBody);
		if (Physics == PHYS_RigidBody)
		{
			//@note: Falling instead of None so Velocity/Acceleration don't get cleared
			SetPhysics(PHYS_Falling);
		}
		Mesh.PhysicsWeight = 1.0;
		Mesh.SetBlockRigidBody(true);
		Mesh.SetHasPhysicsAssetInstance(true);

		if (Mesh.bNotUpdatingKinematicDueToDistance)
		{
		  Mesh.UpdateRBBonesFromSpaceBases(true, true);
		}

		Mesh.PhysicsAssetInstance.SetAllBodiesFixed(false);
		Mesh.bUpdateKinematicBonesFromAnimation = false;
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.ScriptRigidBodyCollisionThreshold = MaxFallSpeed;
		Mesh.SetNotifyRigidBodyCollision(true);
		Mesh.WakeRigidBody();
		Mesh.SetRBLinearVelocity(Velocity, false);
		Mesh.SetTranslation(vect(0,0,1) * 6);

		if( TearOffMomentum != vect(0,0,0) )
		{
			ShotDir = normal(TearOffMomentum);
			ApplyImpulse = ShotDir * DamageType.default.KDamageImpulse;
			// If not moving downwards - give extra upward kick
			if ( Velocity.Z > -10 )
			{
				ApplyImpulse += Vect(0,0,1)*2;
			}
			Mesh.AddImpulse(ApplyImpulse, TakeHitLocation,, true);
		}

		return true;
	}
 
	return false;
}

/* Function:
 * PlayDying(class<DamageType> DamageType, vector HitLoc)
 * Description:
 * This function is called when the pawn dies. This is where the items to be dropped are initialized
 * and then spawned in the physical game world.
 */
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	super.PlayDying(DamageType, HitLoc);

	AddItem = Spawn(class'TS_HealthItem');
	DropItem = Spawn(class'TS_WorldItemPickup');
	DropItem.Initialize(AddItem);
}

/* Function:
 * SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
 * Description:
 * Override this function to do nothing. 
 * TODO: Remember what the purpose of this was...
 */
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}

/* Function:
 * CheckQuests(MyPawn Target)
 * Description:
 * This function checks the status of quests for a player before initializing the correct conversation.
 * Conversations are ordered in the Conversations array by the order they will occur during player interaction.
 * Conversation Index is updated at the beginning of every interaction with the player.
 */
function CheckQuests(MyPawn Target)
{
	if (self.ConversationIndex == 0 && Target.TSConversationManager.CheckDecision(0, 6, 14)) //Nice End to Conversation
	{
		self.ConversationIndex = 1;
	}
	if (self.ConversationIndex == 0 && Target.TSConversationManager.CheckDecision(0, 7, 15)) //Bad End to Conversation
	{
		self.ConversationIndex = 1;
	}
	//Conversation to start initial interaction with NPC
	Target.CurrentNPC = self;
}

defaultproperties
{
	//NPC can converse
	bConverse = True;
	//NPC ID
	PawnID = 1;
	//Health
	HealthMax = 100;

  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=NPCMesh0
    SkeletalMesh=SkeletalMesh'UPK_Characters.Armature'
    PhysicsAsset=PhysicsAsset'UPK_Characters.Armature_Physics'
    AnimSets(0)=AnimSet'UPK_Characters.HumanAnimSet'
    AnimtreeTemplate=AnimTree'UPK_Characters.TS_HumanAnimTree'
  End Object
  NPCMesh=NPCMesh0
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  //Points to your custom AIController class - as the default value
  NPCController=None
}

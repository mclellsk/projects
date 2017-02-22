class TS_WorldItemPickup extends Actor placeable;

var() editconst const CylinderComponent CylinderComponent;
var() editconst const DynamicLightEnvironmentComponent LightEnvironment;
var() int Amount;

//TS_Items object associated with physical representation.
var TS_Items CurrentItem;

//Boolean variable that identifies the TS_WorldItemPickup is ready for pickup.
//Prevents the player from picking up the item, but not receiving the TS_Items
//associated with it.
var bool isInitialized;

/* Event:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned.
 */
event PostBeginPlay()
{
	//Prevents the item from being picked up before the stats have been applied.
	isInitialized = false;

	super.PostBeginPlay();
}

/* Function:
 * Initialize(TS_Items ItemType)
 * Description:
 * This function gives the physical representation of the item the
 * TS_Items object for player inventory management (so that the player
 * gets the item stored in their inventory upon pickup).
 */
function Initialize(TS_Items ItemType)
{
	`log("TSITEM: World Item Initialized");
	if (ItemType != none)
	{
		CurrentItem = ItemType;
		CurrentItem.Initialize();
		isInitialized = true;
	}
}

/* Event:
 * Tick(float DeltaTime)
 * Description:
 * Called after each game tick. Updates the rotation of the physical
 * representation of the item, so that it spins in place to grab
 * player attention.
 */
event Tick(float DeltaTime)
{
	local Rotator newRotation;

	newRotation = self.Rotation;
	newRotation.Yaw += 1000;

	self.SetRotation(newRotation);
	super.Tick(DeltaTime);
}

/* Event:
 * Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
 * Description:
 * Called when the player touches the physical representation of the item. It gives the
 * player the TS_Items object associated with the instance of TS_WorldItemPickup.
 */
event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	local MyPawn TargetPawn;

	if (isInitialized)
	{
		`log("TSITEM: Touched baby");
		super.Touch(Other, OtherComp, HitLocation, HitNormal);

		TargetPawn = MyPawn(Other);
		if (TargetPawn != none)
		{
			GiveTo(TargetPawn);
			PlaySound(CurrentItem.Properties.PickUpSound);
		}
	}
}

/* Function:
 * GiveTo(MyPawn Other)
 * Description:
 * This function gives the TS_Items object associated with the instance of TS_WorldItemPickup
 * to the pawn target "Other" which is the player in almost all cases. Only removes the 
 * physical representation TS_WorldItemPickup if all the TS_Items objects associated with it have
 * been picked up.
 */
function GiveTo(MyPawn Other)
{
	local int AmountToAdd;
	Amount = 1;

	if (Other != None && Other.TSInventoryManager != None)
	{
		AmountToAdd = Other.TSInventoryManager.AddInventoryItem(CurrentItem, Amount);
		//Only remove the item from the world if the item and all of its instances (amount) 
		//could also be picked up by the target pawn.
		if (AmountToAdd > 0)
		{
			Amount = AmountToAdd;
		}
		else
		{
			`log("TSITEM: Item destroyed from world");
			Destroy();
		}
	}
}

DefaultProperties
{
	//Lighting component
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

	//Physical representation model
    Begin Object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'UPK_Misc.Tablet'
        Scale = 1
        LightEnvironment=MyLightEnvironment
    End Object
    Components.Add(BaseMesh)
    
	//Collision model
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+0040.000000
		CollisionHeight=+0040.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bHidden=false
	bCollideActors=true
}

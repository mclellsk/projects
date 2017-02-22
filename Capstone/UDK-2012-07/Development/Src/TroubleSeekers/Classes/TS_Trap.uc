class TS_Trap extends Actor abstract;

var() editconst const CylinderComponent CylinderComponent;
var() editconst const DynamicLightEnvironmentComponent LightEnvironment;

//Damage inflicted
var() float trapDamage;
//Damage type
var class<DamageType> trapDamageType;

/* Event:
 * Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
 * Description:
 * Called after actor touches this trap. The target actor then takes damage based on the trap damage.
 * These traps default to apply crushed type damage.
 */
event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	local MyPawn TargetPawn;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	TargetPawn = MyPawn(Other);
	if (TargetPawn != none)
	{
		TargetPawn.Health-=trapDamage;
		if(TargetPawn.Health <= 0)
		{
			TargetPawn.Died(none, trapDamageType, HitLocation);
		}
	}
	
}

DefaultProperties
{
	//Trap damage
	trapDamage = 10
	//Trap damage type
	trapDamageType = class'DmgType_Crushed'

	bHidden=false
	bCollideActors=true
}
class TS_FallingBlock extends Actor placeable;

var() editconst const CylinderComponent CylinderComponent;
var() editconst const DynamicLightEnvironmentComponent LightEnvironment;
var() float damage;

var MyPawn TargetPawn;
var StaticMesh LoadedStaticMesh;


simulated event PostBeginPlay()
{
	damage = 60;
}
event Touch(Actor Other, PrimitiveComponent OtherComp, Vector HitLocation, Vector HitNormal)
{
	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	TargetPawn = MyPawn(Other);
	if (TargetPawn != none)
	{
		TargetPawn.Health-=damage;
		if(TargetPawn.Health <= 0)
		{
			TargetPawn.Died(none,class'DmgType_Crushed', HitLocation);
		}
	}
	
}

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

    Begin Object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'UPK_Map.falling_block'
        Scale = 1
        LightEnvironment=MyLightEnvironment
    End Object
    Components.Add(BaseMesh)
 
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+0100.000000
		CollisionHeight=+0100.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bHidden=false
	bCollideActors=true
}

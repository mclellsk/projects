class TS_Trap_Spear extends TS_Trap placeable;

DefaultProperties
{
	trapDamage = 10
	trapDamageType = class'DmgType_Crushed'

	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

	//Trap model
    Begin Object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'UPK_Props.dart_projectile'
        Scale = 1
        LightEnvironment=MyLightEnvironment
    End Object
    Components.Add(BaseMesh)
 
	//Trap collision model
    Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+0010.000000
		CollisionHeight=+0010.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bHidden=false
	bCollideActors=true
}

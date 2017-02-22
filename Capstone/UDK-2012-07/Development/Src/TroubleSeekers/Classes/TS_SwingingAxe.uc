class TS_SwingingAxe extends TS_Trap placeable;

DefaultProperties
{
	Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=TRUE
    End Object
    LightEnvironment=MyLightEnvironment
    Components.Add(MyLightEnvironment)

	//Overwrite Default Trap Model
    Begin Object class=StaticMeshComponent Name=BaseMesh
        StaticMesh=StaticMesh'UPK_Map.axe'
        Scale = 1
        LightEnvironment=MyLightEnvironment
    End Object
    Components.Add(BaseMesh)
 
	//Overwrite Default Collision Model
    
	Begin Object Class=CylinderComponent NAME=CollisionCylinder
		CollideActors=true
		CollisionRadius=+0050.000000
		CollisionHeight=+0200.000000
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	//Overwrite Default Trap Damage
	trapDamage = 45
	//Overwrite Default Trap Damage Type
	trapDamageType = class'DmgType_Crushed'

	bHidden=false
	bCollideActors=true
}

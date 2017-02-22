//
// TSWeap_Sword
// This set of DefaultProperties describes the behaviour of the sword weapon in game
//
// Extends from TS_Weapon
//

class TSWeap_Sword extends TS_Weapon;

DefaultProperties
{

    //Determines the ammo count for this weapon's fire types
    ShotCost(0)=0
    ShotCost(1)=0
    MaxSwings=2
    Swings(0)=2
    Swings(1)=2
    MaxAmmoCount=0
    AmmoCount=0
    FireInterval(0)=0.3
    FireInterval(1)=0.7

    //Attributes determining how bots behave with this weapon
    bMeleeWeapon=true;
    bInstantHit=true;
    bCanThrow=false;

    Begin Object class=AnimNodeSequence Name=MeshSequenceA
        bCauseActorAnimEnd=true
    End Object
    
    //Name of the firing state
    FiringStatesArray(0)="Swinging" //TODO: See if this can be moved to TS_Weapon

    //This weapon uses a custom firetype defined in TS_Weapon
    WeaponFireTypes(0)=EWFT_Custom
	WeaponFireTypes(1)=EWFT_Custom
    
    //Socket names on the sword model
    StartSocket = StartSocket
    EndSocket = EndSocket

    //Positioning of model in first-person view
    PlayerViewOffset=(X=40.000000,Y=0.00000,Z=-20.000000) //TODO: Determine if this is needed
    PivotTranslation=(Y=0.0)
    
    //Sets mesh when wielded
    Begin Object Name=FirstPersonMesh //TODO: Combine this with the PickupMesh object
        SkeletalMesh=SkeletalMesh'UPK_Weapons.sword_skeletal'
        FOV=60
        Animations=MeshSequenceA
        AnimSets(0)=AnimSet'UPK_Weapons.Sword_Armature'
        bForceUpdateAttachmentsInTick=True
        Scale=0.9000000
    End Object

    //Sets mesh when on the ground
    Begin Object Name=PickupMesh
        SkeletalMesh=SkeletalMesh'UPK_Weapons.sword_skeletal'
        Scale=0.9000000
    End Object

    //Sound settings
    WeaponEquipSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_RaiseCue'
    WeaponPutDownSnd=SoundCue'A_Weapon_Link.Cue.A_Weapon_Link_LowerCue'
    WeaponFireSnd(0)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_GrenadeFire_Cue'
    WeaponFireSnd(1)=SoundCue'A_Weapon_RocketLauncher.Cue.A_Weapon_RL_GrenadeFire_Cue'
    PickupSound=SoundCue'A_Pickups.Weapons.Cue.A_Pickup_Weapons_Shock_Cue'

    //Number of weapon slot to store weapon
    InventoryGroup=1

    //Damage amounts
    InstantHitDamage(0)=40
    InstantHitDamage(1)=60
    
    //Physical force delivered on hit
    InstantHitMomentum(0)=200
    InstantHitMomentum(1)=300
    
    //InstantHitDamageTypes(0)=Class'TSWeap_Sword_Damage'
    //InstantHitDamageTypes(1)=Class'TSWeap_Sword_Damage'

    //CrosshairImage=Copy texture from Content Browser
    CrossHairCoordinates=(U=384,V=0,UL=64,VL=64)

    //Finalize and apply meshes and animations
    ArmsAnimSet=AnimSet'UPK_Weapons.Sword_Armature'
    Mesh=FirstPersonMesh
    DroppedPickupMesh=PickupMesh
    PickupFactoryMesh=PickupMesh
    AttachmentClass=Class'TSWeap_Sword_Attach'

}
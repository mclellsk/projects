//
// TSWeap_Sword_Ammo
// This set of DefaultProperties describes the behaviour of the sword's physical "ammunition" and how it should be handled in game
// This function isn't particularly useful, but it is one of four default classes required for a weapon to show up in the UDK
//
// Extends from UTAmmoPickupFactory
//

class TSWeap_Sword_Ammo extends UTAmmoPickupFactory;

DefaultProperties
{

    Begin Object Name=AmmoMeshComp
        Translation=(X=0.0,Y=0.0,Z=-16.0)
    End Object

    Begin Object Name=CollisionCylinder
        CollisionHeight=14.4
    End Object

	//Ammo restored on pickup
    AmmoAmount=1

    PickupSound=SoundCue'A_Pickups.Ammo.Cue.A_Pickup_Ammo_Link_Cue'

    TargetWeapon=Class'TSWeap_Sword'
}
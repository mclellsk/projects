//
// TSWeap_Sword_Damage
// This set of DefaultProperties helps define the properties of the sword's damage function
// This function isn't particularly useful, but it is one of four default classes required for a weapon to show up in the UDK
//
// Extends from UTDamageType
//

class TSWeap_Sword_Damage extends UTDamageType;

DefaultProperties
{

    bBulletHit=False
    bCausesBlood=True
    bCausesBloodSplatterDecals=True
    bComplainFriendlyFire=False
    GibPerterbation=0.060000
    KDamageImpulse=200
    VehicleDamageScaling=0.150000

    DamageWeaponClass=Class'TSWeap_Sword'

}

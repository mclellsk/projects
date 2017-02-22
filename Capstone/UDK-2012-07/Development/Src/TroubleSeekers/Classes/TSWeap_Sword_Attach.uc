//
// TSWeap_Sword_Attach
// This set of DefaultProperties helps define how the sword's skeleton works with its model
// This function isn't particularly useful, but it is one of four default classes required for a weapon to show up in the UDK
//
// Extends from UTWeaponAttachment
//

class TSWeap_Sword_Attach extends UTWeaponAttachment;

DefaultProperties
{

    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'UPK_Weapons.sword_skeletal'
        CullDistance=5000.000000
        Scale=1
    End Object

    bMakeSplash=False

    Mesh=SkeletalMeshComponent0
    WeaponClass=Class'TSWeap_Sword'
}

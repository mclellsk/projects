class TutorialPawn_NPC extends UTPawn
  placeable;
   
var(NPC) SkeletalMeshComponent NPCMesh;
var(NPC) class<AIController> NPCController;

simulated event PostBeginPlay()
{
  if(NPCController != none)
  {
    //set the existing ControllerClass to our new NPCController class
    ControllerClass = NPCController;
  }
   
  Super.PostBeginPlay();
}

//override to do nothing
simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
{
}

defaultproperties
{
  //Setup default NPC mesh
  Begin Object Class=SkeletalMeshComponent Name=NPCMesh0
    SkeletalMesh=SkeletalMesh'UPK_Characters.Armature'
    //PhysicsAsset=PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics'
    AnimSets(0)=AnimSet'UPK_Characters.HumanAnimSet'
    AnimtreeTemplate=AnimTree'UPK_Characters.TS_HumanAnimTree'
  End Object
  NPCMesh=NPCMesh0
  Mesh=NPCMesh0
  Components.Add(NPCMesh0)

  //Points to your custom AIController class - as the default value
  NPCController=class'TutorialPawn_Controller'
  SuperHealthMax=100
}
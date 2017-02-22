class MyPawn extends TS_Pawn dependson (TS_Items);

var(NPC) class NPCController;

//Inventory Manager
var class<MyInventoryManager> TSInventory;
var MyInventoryManager TSInventoryManager;
//Event Manager
var TS_EventManager TSEventManager;
var TS_ConversationManager TSConversationManager;

//Name of the NPC who is currently being interacted with
var TS_Pawn CurrentNPC;
//List of notifications
var array<TS_Notification> NotificationList;
//List of HitValues
var array<TS_FloatDmg> FloatDmgList;

//Distance to offset the camera from the player
var float CamOffsetDistance; 
//Pitch angle of the camera
var int IsoCamAngle; 

//Represents whether corresponding active slot is used
var bool InUseSlot1;
var bool InUseSlot2;
var bool InUseSlot3;
var bool InUseSlot4;
var bool InUseSlot5;

//Nathan's Variables
//var const Name SwordHandSocketName;
/*var AnimNodePlayCustomAnim SwingAnim;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        SwingAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('SwingCustomAnim'));
    }
}*/

/* Event:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned. Initializes the inventory manager for this pawn
 * and the event manager for this pawn.
 */
simulated function PostBeginPlay() 
{
    local TS_LightningItem fireball;
    local TS_StormItem storm;

    super.PostBeginPlay();

    if (TSInventory != None)
    {
        TSInventoryManager = Spawn(TSInventory, Self);
        if (TSInventoryManager == None)
        {
        }
    }

    TSEventManager = Spawn(class'TS_EventManager', Self);
    TSConversationManager = Spawn(class'TS_ConversationManager', Self);
    TSConversationManager.Initialize();

	//TSEventManager.QuestManager.MoveQuestToCurrent(4);

    InUseSlot1 = false;
}

/* Event:
 * BecomeViewTarget(PlayerController PC)
 * Description:
 * Override to make player mesh visible by default.
 */
simulated event BecomeViewTarget(PlayerController PC)
{
   local UTPlayerController UTPC;

   Super.BecomeViewTarget(PC);

   if (LocalPlayer(PC.Player) != None)
   {
      UTPC = UTPlayerController(PC);
      if (UTPC != None)
      {
         //Set player controller to behind view and make mesh visible
         UTPC.SetBehindView(true);
         SetMeshVisibility(true); 
         UTPC.bNoCrosshair = true;
      }
   }
}

/* Event:
 * Tick(float DeltaTime)
 * Description:
 * Called every game tick. Updates the stats of the pawn based on whether any changes to the inventory have occurred.
 * Also updates the state of the event manager, checking if the quests are complete or updating progress.
 */
simulated event Tick(float DeltaTime)
{
    //Update the Quest Manager
    //TSEventManager.QuestManager.Tick(DeltaTime);

    super.Tick(DeltaTime);

    if (TSInventoryManager.HasInventoryChanged)
    {
        UpdateStats();

        //Go back to waiting for inventory change
        TSInventoryManager.HasInventoryChanged = false;
    }
}

//Create Notification
function CreateNotification(string message)
{
    local TS_Notification notification;

    notification = Spawn(class'TS_Notification', self);
    notification.Initialize(2, message);
    NotificationList.AddItem(notification);
}

//Create Notification
function CreateFloatDmg(Vector pos, string message)
{
    local TS_FloatDmg floatdmg;

    floatdmg = Spawn(class'TS_FloatDmg', self);
    floatdmg.Initialize(pos, 2, message);
    FloatDmgList.AddItem(floatdmg);
}

/* Function:
 * UpdateStats()
 * Description:
 * This function updates the stats of the player. It first restores the base stats,
 * then applies all new bonuses to the player based on the passives container.
 */
function UpdateStats()
{
    local int i;

    //Restore default stats
    self.HealthMax = BaseHealthMax;
    self.GroundSpeed = BaseMoveSpeed;
    self.FireRateMultiplier = BaseAttackSpeed;
    self.ManaMax = BaseManaMax;
    self.RegenHealthPerSec = BaseRegenHealthPerSec;
    self.RegenManaPerSec = BaseRegenManaPerSec;
    

    for (i = 0; i < TSInventoryManager.PassivesContainer.Length; i++)
    {
        //Update all stats
        CheckAllProperties(TSInventoryManager.PassivesContainer[i]);
    }
}

/* Function:
 * CheckAllProperties(TS_Items CheckItem)
 * Description:
 * This function checks the properties of a TS_Items object, if it is of type TS_Empty,
 * then no properties are changed. If not, the appropriate bonuses are applied to the 
 * player stats.
 */
function CheckAllProperties(TS_Items CheckItem)
{
    local int i;
    local Bonus bonusType;

    if (CheckItem.Class != class'TS_Empty')
    {
        for (i = 0; i < CheckItem.BonusList.Length; i++)
        {
            bonusType = CheckItem.BonusList[i].PropertyName;
            switch (bonusType)
            {
                case MaxHealthBonus:
                    self.HealthMax += CheckItem.BonusList[i].Value;
                    break;
                case AttackSpeedBonus:
                    self.FireRateMultiplier /= CheckItem.BonusList[i].Value;
                    break;
                case MovementSpeedBonus:
                    self.GroundSpeed += CheckItem.BonusList[i].Value;
                    break;
                case MaxManaBonus:
                    self.ManaMax += CheckItem.BonusList[i].Value;
                    break;
                case ManaRegenFlatBonus:
                    self.RegenManaPerSec += CheckItem.BonusList[i].Value;
                    break;
                case HealthRegenFlatBonus:
                    self.RegenHealthPerSec += CheckItem.BonusList[i].Value;
                    break;
            }
        }
    }
}

/* Function:
 * bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
 * Description:
 * This function updates the player pawn camera.
 * TODO: Switch this functionality to the TS_Camera extended class.
 */
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    /*
   out_CamLoc = Location;
   out_CamLoc.X -= Cos(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;
   out_CamLoc.Z += Sin(IsoCamAngle * UnrRotToRad) * CamOffsetDistance;

   out_CamRot.Pitch = -1 * IsoCamAngle;   
   out_CamRot.Yaw = 0;
   out_CamRot.Roll = 0;

   return true;
   */
}

/* Event:
 * Rotator GetBaseAimRotation()
 * Description:
 * This event controls the pawn's aim. It is restricted to change the Yaw of the player only. 
 * Pitch and Roll have no effect on aim.
 */
simulated singular event Rotator GetBaseAimRotation()
{
   local rotator POVRot, tempRot;

   tempRot = Rotation;
   tempRot.Pitch = 0;
   SetRotation(tempRot);
   POVRot = Rotation;
   POVRot.Pitch = 0;

   return POVRot;
}

/* Function:
 * UseActiveSlot1()
 * Description:
 * This function is called when the player presses the hotkey keyboard 1. Set in the DefaultInput.cfg.
 */
exec function UseActiveSlot1()
{
    CheckSpells(0);
}

/* Function:
 * UseActiveSlot2()
 * Description:
 * This function is called when the player presses the hotkey keyboard 2. Set in the DefaultInput.cfg.
 */
exec function UseActiveSlot2()
{
    CheckSpells(1);
}

/* Function:
 * UseActiveSlot3()
 * Description:
 * This function is called when the player presses the hotkey keyboard 3. Set in the DefaultInput.cfg.
 */
exec function UseActiveSlot3()
{
    CheckSpells(2);
}

/* Function:
 * UseActiveSlot4()
 * Description:
 * This function is called when the player presses the hotkey keyboard 4. Set in the DefaultInput.cfg.
 */
exec function UseActiveSlot4()
{
    CheckSpells(3);
}

/* Function:
 * UseActiveSlot5()
 * Description:
 * This function is called when the player presses the hotkey keyboard 5. Set in the DefaultInput.cfg.
 */
exec function UseActiveSlot5()
{
    CheckSpells(4);
}

/* Function:
 * Interact()
 * Description:
 * This function is called when the player presses the hotkey keyboard E. Set in the DefaultInput.cfg. It takes the closest collidable actor
 * and attempts to open an interaction with the player.
 */
exec function Interact()
{
    CheckInteraction_NeutralVillager1();
	CheckInteraction_NeutralVillager2();
}

function CheckInteraction_NeutralVillager1()
{
    local TS_Neutral_Villager_1 Target;
    local TraceHitInfo HitInfo;

    //Interaction with Neutral Villager 1
    foreach VisibleCollidingActors(class'TS_Neutral_Villager_1',Target,50,,,,,,HitInfo )
    {
        if (!Target.bWorldGeometry)
        {
            if (Target.bConverse)
            {
                Target.CheckQuests(self);
                self.TSConversationManager.SetConversation(Target.PawnID, Target.ConversationIndex);
                self.TSConversationManager.bInConversation = true;
            }
        }
    }
}

function CheckInteraction_NeutralVillager2()
{
    local TS_Neutral_Villager_2 Target;
    local TraceHitInfo HitInfo;

    //Interaction with Neutral Villager 1
    foreach VisibleCollidingActors(class'TS_Neutral_Villager_2',Target,50,,,,,,HitInfo )
    {
        if (!Target.bWorldGeometry)
        {
            if (Target.bConverse)
            {
                Target.CheckQuests(self);
                self.TSConversationManager.SetConversation(Target.PawnID, Target.ConversationIndex);
                self.TSConversationManager.bInConversation = true;
            }
        }
    }
}



/* Function:
 * CheckSpells(int slot)
 * Description:
 * This function checks the active and passive slot of the associated slot number for the correct spell to cast.
 * Checks which passives to apply, changes some functionality of the cast, checks the number of casts called per slot spell.
 * This function also checks if the player has the minimum amount of mana required to cast the spell, then reduces the amount
 * from the current mana and then calls the function which actually casts the spell associated with the slot.
 */
function CheckSpells(int slot)
{
    local int manaCost;
    local int i, j;
    local PassiveSpellNames passiveSpellName;
    local int numberOfCasts;

    //Default number of casts for a spell is 1
    numberOfCasts = 1;
    
    if (self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList.Length > 0)
    {
        for (i = 0; i < self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList.Length; i++)
        {
            passiveSpellName = self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList[i].PassiveSpellName;
            
            if (passiveSpellName == Multishot)
            {
                for (j = 0; j < self.TSInventoryManager.ActivesContainer[slot].SpellList.Length; j++)
                {
                    //If the spell equipped is Heal
                    if (self.TSInventoryManager.ActivesContainer[slot].SpellList[j].SpellName == Heal)
                    {
                        if (isChaosEquipped(PassivesEquipped()))
                        {
                            numberOfCasts = GenerateValue(30, 2, self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList[i].MultishotValue + 4);
                        }
                        else
                        {
                            numberOfCasts = self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList[i].MultishotValue;
                        }
                        break;
                    }
                }
            }
            else if (passiveSpellName == Storm)
            {
                for (j = 0; j < self.TSInventoryManager.ActivesContainer[slot].SpellList.Length; j++)
                {
                    //If the spell equipped is Heal
                    if (self.TSInventoryManager.ActivesContainer[slot].SpellList[j].SpellName == Heal)
                    {
                        break;
                    }
                    else
                    {
                        if (isChaosEquipped(PassivesEquipped()))
                        {
                            numberOfCasts = GenerateValue(30, 2, self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList[i].MulticastValue + 4);
                        }
                        else
                        {
                            numberOfCasts = self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList[i].MulticastValue;
                        }
                    }
                }
            }
        }
    }

    RemainingCasts[slot] = numberOfCasts;

    if (self.TSInventoryManager.ActivesContainer.Length != 0)
    {
        manaCost = self.TSInventoryManager.ActivesContainer[slot].ManaCost;
    
        //Functional effects from spells go here
        if (self.Mana >= manaCost)
        {
            //Reduce mana by cost
            self.Mana -= manaCost;
            if (slot == 0)
                CastSlot1();
            else if (slot == 1)
                CastSlot2();
            else if (slot == 2)
                CastSlot3();
            else if (slot == 3)
                CastSlot4();
            else if (slot == 4)
                CastSlot5();
        }
    }
}

/* Function:
 * CastSlot1()
 * Description:
 * This function calls the CastSpells function and sets the slot to index 0, and reduces the number of casts remaining for the particular spell (if multicast i.e. storm)
 * by one. If the number of casts remaining is greater than 0, it puts another cast on a timer to be called in 0.25 seconds.
 */
function CastSlot1()
{
    local int slot;

    ClearTimer('CastSlot1');
    RemainingCasts[0] -= 1;

    if (Remainingcasts[0] > 0)
        SetTimer(0.25, false, 'CastSlot1');

    //Slot corresponding to this function
    slot = 0;
    CastSpells(slot);
}

/* Function:
 * CastSlot2()
 * Description:
 * This function calls the CastSpells function and sets the slot to index 1, and reduces the number of casts remaining for the particular spell (if multicast i.e. storm)
 * by one. If the number of casts remaining is greater than 0, it puts another cast on a timer to be called in 0.25 seconds.
 */
function CastSlot2()
{
    local int slot;

    ClearTimer('CastSlot2');
    RemainingCasts[1] -= 1;

    if (Remainingcasts[1] > 0)
        SetTimer(0.25, false, 'CastSlot2');

    //Slot corresponding to this function
    slot = 1;
    CastSpells(slot);
}

/* Function:
 * CastSlot3()
 * Description:
 * This function calls the CastSpells function and sets the slot to index 2, and reduces the number of casts remaining for the particular spell (if multicast i.e. storm)
 * by one. If the number of casts remaining is greater than 0, it puts another cast on a timer to be called in 0.25 seconds.
 */
function CastSlot3()
{
    local int slot;

    ClearTimer('CastSlot3');
    RemainingCasts[2] -= 1;

    if (Remainingcasts[2] > 0)
        SetTimer(0.25, false, 'CastSlot3');

    //Slot corresponding to this function
    slot = 2;
    CastSpells(slot);
}

/* Function:
 * CastSlot4()
 * Description:
 * This function calls the CastSpells function and sets the slot to index 3, and reduces the number of casts remaining for the particular spell (if multicast i.e. storm)
 * by one. If the number of casts remaining is greater than 0, it puts another cast on a timer to be called in 0.25 seconds.
 */
function CastSlot4()
{
    local int slot;

    ClearTimer('CastSlot4');
    RemainingCasts[3] -= 1;

    if (Remainingcasts[3] > 0)
        SetTimer(0.25, false, 'CastSlot4');

    //Slot corresponding to this function
    slot = 3;
    CastSpells(slot);
}

/* Function:
 * CastSlot5()
 * Description:
 * This function calls the CastSpells function and sets the slot to index 4, and reduces the number of casts remaining for the particular spell (if multicast i.e. storm)
 * by one. If the number of casts remaining is greater than 0, it puts another cast on a timer to be called in 0.25 seconds.
 */
function CastSlot5()
{
    local int slot;

    ClearTimer('CastSlot5');
    RemainingCasts[4] -= 1;

    if (Remainingcasts[4] > 0)
        SetTimer(0.25, false, 'CastSlot5');

    //Slot corresponding to this function
    slot = 4;
    CastSpells(slot);
}

/* Function:
 * CastSpells(int slot)
 * Description:
 * This function calls the appropriate spell to cast depending on the active in the designated slot. It is possible to call more than one spell
 * from the same slot active, which is why it iterates through all spells in the activescontainer[slot].spellList.
 */
function CastSpells(int slot)
{
    local array<SpellInfo> spells;
    local int i;

    if (self.TSInventoryManager.ActivesContainer.Length != 0)
    {
        spells = self.TSInventoryManager.ActivesContainer[slot].SpellList;
    
        for (i = 0; i < spells.Length; i++)
        {
            switch (spells[i].SpellName)
            {
                case Fireball:
                    UseSpellFireball(spells[i], self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList, self.TSInventoryManager.ActivesContainer[slot].StatusEffectList, PassivesEquipped());
                    break;
                case Poisonball:
                    UseSpellPoisonball(spells[i], self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList, self.TSInventoryManager.ActivesContainer[slot].StatusEffectList, PassivesEquipped());
                    break;
                case Heal:
                    UseSpellHeal(spells[i], self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList, self.TSInventoryManager.ActivesContainer[slot].StatusEffectList, PassivesEquipped());
                    break;
                case Lightning:
                    UseSpellLightning(spells[i], self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList, self.TSInventoryManager.ActivesContainer[slot].StatusEffectList, PassivesEquipped());
                    break;
                case Curse:
                    UseSpellCurse(spells[i], self.TSInventoryManager.PassivesContainer[slot].PassiveSpellList, self.TSInventoryManager.ActivesContainer[slot].StatusEffectList, PassivesEquipped());
                    break;
            }
        }
    }
}

/* Function:
 * array<PassiveSpellInfo> PassivesEquipped()
 * Description:
 * This function returns an array containing all the passives equipped on the player, regardless of the slot.
 */
function array<PassiveSpellInfo> PassivesEquipped()
{
    local array<PassiveSpellInfo> passivesEquipped;
    local int i,j;

    for (i = 0; i < self.TSInventoryManager.PassivesContainer.Length; i++)
    {
        for (j = 0; j < self.TSInventoryManager.PassivesContainer[i].PassiveSpellList.Length; j++)
        {
            passivesEquipped.AddItem(self.TSInventoryManager.PassivesContainer[i].PassiveSpellList[j]);
        }
    }

    return passivesEquipped;
}

/* Function:
 * name GetDefaultCameraMode(PlayerController RequestedBy)
 * Description:
 * This function is supposed to be overwritten for the TS_Camera implementation of the camera.
 * TODO: Needs to be fixed to work with new camera implementation.
 */
function name GetDefaultCameraMode(PlayerController RequestedBy)
{
    super.GetDefaultCameraMode(RequestedBy);
}

defaultproperties
{
    //SwordHandSocketName = WeaponPoint

    bCanPickUpInventory = true;
    TSInventory = MyInventoryManager;

    //IsoCamAngle=6420 35.264 degrees
    IsoCamAngle=10922 //60 deg
    CamOffsetDistance=1000
   
    WalkingPct=+0.4
    CrouchedPct=+0.4
    BaseEyeHeight=38.0
    EyeHeight=38.0
    GroundSpeed=400.0
    AirSpeed=440.0
    WaterSpeed=220.0
    DodgeSpeed=200.0
    DodgeSpeedZ=295.0
    AccelRate=2048.0
    JumpZ=322.0
    CrouchHeight=29.0
    CrouchRadius=21.0
    WalkableFloorZ=.75
    AlwaysRelevantDistanceSquared=+1960000.0

    NPCController=class'TroubleSeekers.MyPlayerController'

    MeleeRange=+20.0
    bMuffledHearing=true
    Buoyancy=+000.99000000
    UnderWaterTime=+00020.000000
    bCanStrafe=True
    bCanSwim=true
    RotationRate=(Pitch=20000,Yaw=20000,Roll=20000)
    MaxLeanRoll=2048
    AirControl=+0.35
    DefaultAirControl=+0.35
    bCanCrouch=true
    bCanClimbLadders=True
    bCanPickupInventory=True
    bCanDoubleJump=true
    SightRadius=+3000.0
    FireRateMultiplier=5.0

    MaxMultiJump=1
    MultiJumpRemaining=10
    MultiJumpBoost=-95.0
     
    SoundGroupClass=class'UTGame.UTPawnSoundGroup'

    TransInEffects(0)=class'UTEmit_TransLocateOutRed'
    TransInEffects(1)=class'UTEmit_TransLocateOut'

    MaxStepHeight=35.0
    MaxJumpHeight=69.0
    MaxDoubleJumpHeight=87.0
    DoubleJumpEyeHeight=43.0
    SuperHealthMax=9000

    Begin Object Name=WPawnSkeletalMeshComponent
        bOwnerNoSee=false
    End Object
    Name="Default__MyPawn"
}
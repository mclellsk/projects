class GFxHUD extends GFxMoviePlayer dependson(MyPawn);

//Previous Health of the Player
var float oldPlayerHealth;
//Previous Mana of the Player
var float oldPlayerMana;
//Maximum number of actives and passives to display on hud.
//NOTE: Do not change this without changing the flash file.
var int maxDisplaySlots;
//Maximum number of status effects to display on hud.
//NOTE: Do not change this without changing the flash file.
var int maxStatusEffects;

//Initialize Flash Objects
var GFxObject healthFill;
var GFxObject healthMaskCloud;
var GFxObject healthText;
var GFxObject manaFill;
var GFxObject manaMaskCloud;
var GFxObject manaText;

//Initialize array of Active, Passive and Status Effect Flash Objects
var array<GFxObject> activeSlotDisplays;
var array<GFxObject> passiveSlotDisplays;
var array<GFxObject> statusEffectDisplays;

/* Function:
 * int roundNum(float NumIn)
 * Description:
 * This function rounds a float to the nearest integer value.
 */
function int roundNum(float NumIn) 
{
	local int iNum;
	local float fNum;

	fNum = NumIn;
	iNum = int(fNum);
	fNum -= iNum;

	if (fNum >= 0.5f) {
		return (iNum + 1);
	}
	else {
		return iNum;
	}
}

/* Function:
 * int getpercent(int val, int max) 
 * Description:
 * This function returns a percentage from a value and a maximum
 */
function int getpercent(int val, int max) 
{
	return roundNum((float(val) / float(max)) * 100.0f);
}

/* Function:
 * Initialize(optional LocalPlayer LocPlay)
 * Description:
 * This function initializes the Flash objects with the correct movieClip references and loads the SWF movie containing
 * the Heads-up Display.
 */
function Initialize(optional LocalPlayer LocPlay)
{
	local string slotName;
	local int i;

	LocalPlayerOwnerIndex = class'Engine'.static.GetEngine().GamePlayers.Find(LocPlay);
	if(LocalPlayerOwnerIndex == INDEX_NONE)
	{
		LocalPlayerOwnerIndex = 0;
	}

	//Start and load the SWF Movie
	Start();
	Advance(0.f);

	//Set the cache value so that it will get updated on the first Tick
	oldPlayerHealth = -1337;
	oldPlayerMana = -1337;

	//Load the references with pointers to the movieClips and text fields in the .swf
	healthFill = GetVariableObject("_root.Main_Health.Health_Background_Outer.Health_Background_Inner");
	healthMaskCloud = GetVariableObject("_root.Main_Health.Health_Background_Outer.Mask_Cloud");
	healthText = GetVariableObject("_root.Health_Display");
	manaFill = GetVariableObject("_root.Main_Mana.Mana_Background_Outer.Mana_Background_Inner");
	manaMaskCloud = GetVariableObject("_root.Main_Mana.Mana_Background_Outer.Mask_Cloud");
	manaText = GetVariableObject("_root.Mana_Display");

	maxDisplaySlots = 5;
	maxStatusEffects = 7;

	for (i = 0; i < maxDisplaySlots; i++)
	{
		slotName = ("_root.active_slot"$(i+1));
		activeSlotDisplays.addItem(GetVariableObject(slotName));
	}

	for (i = 0; i < maxDisplaySlots; i++)
	{
		slotName = ("_root.passive_slot"$(i+1));
		passiveSlotDisplays.addItem(GetVariableObject(slotName));
	}

	for (i = 0; i < maxStatusEffects; i++)
	{
		slotName = ("_root.statuseffectsbar.statuseffect_"$(i+1));
		statusEffectDisplays.addItem(GetVariableObject(slotName));
	}
}

/* Function:
 * TickHUD() 
 * Description:
 * This function is called every game tick, which updates the contents of the health bar, mana bar, actives displayed, passives displayed and status effects
 * displayed.
 */
function TickHUD() 
{	
	UpdateHealthBar();
	UpdateManaBar();
	UpdateActives();
	UpdatePassives();
	UpdateStatusEffects();
}

/* Function:
 * UpdateActives()
 * Description:
 * This function updates the HUD to display the contents of the active items in the inventory manager for the pawn.
 */
function UpdateActives()
{
	local MyPawn Player1;
	local array<TS_Items> activesContainer;
	local int i;

	Player1 = MyPawn(GetPC().Pawn);
	activesContainer = Player1.TSInventoryManager.ActivesContainer;

	for (i = 0; i < activesContainer.Length; i++)
	{
		activeSlotDisplays[i].GetObject("slot").GotoAndStop(activesContainer[i].Properties.ItemIcon);
	}
}

/* Function:
 * UpdatePassives()
 * Description:
 * This function updates the HUD to display the contents of the passive items in the inventory manager for the pawn.
 */
function UpdatePassives()
{
	local MyPawn Player1;
	local array<TS_Items> passivesContainer;
	local int i;

	Player1 = MyPawn(GetPC().Pawn);
	passivesContainer = Player1.TSInventoryManager.PassivesContainer;

	for (i = 0; i < passivesContainer.Length; i++)
	{
		passiveSlotDisplays[i].GetObject("slot").GotoAndStop(passivesContainer[i].Properties.ItemIcon);
	}
}

/* Function:
 * UpdateStatusEffects()
 * Description:
 * This function updates the HUD to display the current status effects being applied to the pawn.
 */
function UpdateStatusEffects()
{
	local MyPawn Player1;
	local array<StatusEffects> statusEffectsContainer;
	local StatusEffects statusEffect;
	local int i;

	Player1 = MyPawn(GetPC().Pawn);
	statusEffectsContainer = Player1.statusEffectsContainer;

	//Clear the current status effects in case some are finished
	for (i = 0; i < statusEffectDisplays.Length; i++)
	{
		statusEffectDisplays[i].GotoAndStop("Empty");
	}

	//Update the current status effects to correctly show them
	//There need to be at least as many displays as there are possible effects, unless this is fixed.
	for (i = 0; i < statusEffectsContainer.Length; i++)
	{
		statusEffect = statusEffectsContainer[i];
		switch (statusEffect)
		{
			case isBurning:
				statusEffectDisplays[i].GotoAndStop("Burning");
				break;
			case isPoisoned:
				statusEffectDisplays[i].GotoAndStop("Poison");
				break;
			case isZombified:
				statusEffectDisplays[i].GotoAndStop("Curse");
				break;
		}
	}
}

/* Function:
 * UpdateHealthBar()
 * Description:
 * This function updates the HUD to display the current health of the pawn.
 */
function UpdateHealthBar()
{
	local MyPawn Player1;
	local string healthMessage;
	local float healthPercentage;
	Player1 = MyPawn(GetPC().Pawn);

	if (oldPlayerHealth != Player1.Health) 
	{
		oldPlayerHealth = Player1.Health;
		healthPercentage = getpercent(oldPlayerHealth, Player1.HealthMax);

		if (healthPercentage > 100)
			healthPercentage = 100;
		else if (healthPercentage < 0)
			healthPercentage = 0;

		healthFill.SetFloat("_yscale", healthPercentage);
		healthMaskCloud.SetFloat("_yscale", healthPercentage);
		healthMessage = ("Health: " $ string(round(oldPlayerHealth)) $ "/" $ string(Player1.HealthMax));
		healthText.SetString("text", healthMessage);
	}
}

/* Function:
 * UpdateManaBar()
 * Description:
 * This function updates the HUD to display the current mana of the pawn.
 */
function UpdateManaBar()
{
	local MyPawn Player1;
	local string manaMessage;
	local float manaPercentage;
	Player1 = MyPawn(GetPC().Pawn);

	if (oldPlayerMana != Player1.Mana) 
	{
		oldPlayerMana = Player1.Mana;
		manaPercentage = getpercent(oldPlayerMana, Player1.ManaMax);

		if (manaPercentage > 100)
			manaPercentage = 100;
		else if (manaPercentage < 0)
			manaPercentage = 0;

		manaFill.SetFloat("_yscale", manaPercentage);
		manaMaskCloud.SetFloat("_yscale", manaPercentage);
		manaMessage = ("Mana: " $ string(round(oldPlayerMana)) $ "/" $ string(Player1.ManaMax));
		manaText.SetString("text", manaMessage);
	}
}

DefaultProperties
{
	bDisplayWithHudOff=false
	//SWF Containing HUD
	MovieInfo=SwfMovie'TroubleSeekers_HUD.TS_HUD'
	bEnableGammaCorrection = false
}

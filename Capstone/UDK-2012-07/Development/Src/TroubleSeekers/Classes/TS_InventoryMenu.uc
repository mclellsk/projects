class TS_InventoryMenu extends GFxMoviePlayer dependson (TS_Items);

//Root Flash Object
var GFxObject RootMC;
//Actionscript Arguments
var array<ASValue> args;
//Inventory Slot Flash Objects
var array<GFxObject> InventorySlot;
//Passive Slot Flash Objects
var array<GFxObject> PassivesSlot;
//Active Slot Flash Objects
var array<GFxObject> ActivesSlot;

/* Function:
 * Initialize(optional LocalPlayer LocPlay)
 * Description:
 * This function initializes each GFxObject, associating it with the 
 * correct flash movie clip object/instance.
 */
function Initialize(optional LocalPlayer LocPlay)
{
	local MyPawn Player1;
	local string InventoryInstance;
	local int i;

	RootMC = GetVariableObject("_root");
	Player1 = MyPawn(GetPC().Pawn);

	//Clear InventorySlot array
	for (i = 0; i < InventorySlot.Length; i++)
	{
		InventorySlot.Remove(i,1);
		i--;
	}

	//Clear PassivesSlot array
	for (i = 0; i < PassivesSlot.Length; i++)
	{
		PassivesSlot.Remove(i,1);
		i--;
	}

	//Clear ActivesSlot array
	for (i = 0; i < ActivesSlot.Length; i++)
	{
		ActivesSlot.Remove(i,1);
		i--;
	}
	
	//Load the inventory slots (24 Slots)
	for (i = 0; i < Player1.TSInventoryManager.InventoryContainerSize; i++)
	{
		InventoryInstance = ("_root.inventory_slot" $ (i + 1));
		InventorySlot.AddItem(GetVariableObject(InventoryInstance));
	}

	//Load the passives slots (5 Slots)
	for (i = 0; i < Player1.TSInventoryManager.PassivesContainerSize; i++)
	{
		InventoryInstance = ("_root.passive_slot" $ (i + 1));
		PassivesSlot.AddItem(GetVariableObject(InventoryInstance));
	}

	//Load the actives slots (5 Slots)
	for (i = 0; i < Player1.TSInventoryManager.ActivesContainerSize; i++)
	{
		InventoryInstance = ("_root.active_slot" $ (i + 1));
		ActivesSlot.AddItem(GetVariableObject(InventoryInstance));
	}
}

/* Function:
 * TickHUD()
 * Description:
 * This function updates the contents of the Inventory Menu objects to reflect the 
 * player inventory in real time. Runs once every game tick.
 */
function TickHUD()
{
	local MyPawn _Player;
	local TS_Items CurrentItem;
	local int i;
	
	_Player = MyPawn(GetPC().Pawn);

	//Update UI Passives Elements to reflect contents of Passives
	for (i = 0; i < _Player.TSInventoryManager.PassivesContainer.Length; i++)
	{
		CurrentItem = _Player.TSInventoryManager.PassivesContainer[i];
		if (CurrentItem != none)
		{
			PassivesSlot[i].GetObject("slot").GotoAndStop(CurrentItem.Properties.ItemIcon);
		}
	}

	//Update UI Passives Elements to reflect contents of Actives
	for (i = 0; i < _Player.TSInventoryManager.ActivesContainer.Length; i++)
	{
		CurrentItem = _Player.TSInventoryManager.ActivesContainer[i];
		if (CurrentItem != none)
		{
			ActivesSlot[i].GetObject("slot").GotoAndStop(CurrentItem.Properties.ItemIcon);
		}
	}

	//Update UI Inventory Elements to reflect contents of Inventory
	for (i = 0; i < _Player.TSInventoryManager.InventoryContainer.Length; i++)
	{
		CurrentItem = _Player.TSInventoryManager.InventoryContainer[i];
		if (CurrentItem != none)
		{
			InventorySlot[i].GetObject("slot").GotoAndStop(CurrentItem.Properties.ItemIcon);
		}
	}
}

/* Event:
 * RollOverItem(int slot)
 * Description:
 * This event checks to see if the inventory slot selected is empty before displaying the item info box.
 * It then calls the actionscript "CallOpenInfo" function if the slot is not empty.
 */
event RollOverItem(int slot)
{
	local MyPawn Player1;
	Player1 = MyPawn(GetPC().Pawn);

	if (Player1.TSInventoryManager.InventoryContainer[slot].Class != class'TS_Empty')
	{
		//Player1.WorldInfo.Game.Broadcast(Player1, "Over Item");
		CallOpenInfo(slot);
	}
}

/* Event:
 * RollOverPassive(int slot)
 * Description:
 * This function checks to see if the passive slot selected is empty before displaying the item info box.
 * It then calls the actionscript "CallOpenPassiveInfo" function if the slot is not empty.
 */
event RollOverPassive(int slot)
{
	local MyPawn Player1;
	Player1 = MyPawn(GetPC().Pawn);

	if (Player1.TSInventoryManager.PassivesContainer[slot].Class != class'TS_Empty')
	{
		//Player1.WorldInfo.Game.Broadcast(Player1, "Over Passive");
		CallOpenPassiveInfo(slot);
	}
}

/* Event:
 * RollOverActive(int slot)
 * Description:
 * This function checks to see if the active slot selected is empty before displaying the item info box.
 * It then calls the actionscript "CallOpenActiveInfo" function if the slot is not empty.
 */
event RollOverActive(int slot)
{
	local MyPawn Player1;
	Player1 = MyPawn(GetPC().Pawn);

	if (Player1.TSInventoryManager.ActivesContainer[slot].Class != class'TS_Empty')
	{
		//Player1.WorldInfo.Game.Broadcast(Player1, "Over Active");
		CallOpenActiveInfo(slot);
	}
}

/* Function:
 * SetInfo(string MCName, int slot, string slotType)
 * Description:
 * This function updates the display information for the item in the slot that triggered the "mouseOver" event
 * and is called by actionscript when a movieclip item slot triggers mouseOver.
 */
function SetInfo(string MCName, int slot, string slotType)
{
	local MyPawn Player1;
	//Flash Object Elements
	local GFxObject itemInfo, itemType, itemName, itemDescription;
	local array<TS_Items> container;
	local string description;
	local Bonus bonusType;
	local SpellNames spellType;
	local PassiveSpellNames passiveSpellType;
	local int i;

	Player1 = MyPawn(GetPC().Pawn);

	//Checks which array of items the slot corresponds to.
	switch (slotType)
	{
		case "Inventory":
			container = Player1.TSInventoryManager.InventoryContainer;
			break;
		case "Passives":
			container = Player1.TSInventoryManager.PassivesContainer;
			break;
		case "Actives":
			container = Player1.TSInventoryManager.ActivesContainer;
			break;
	}

	//Update flash object properties
	itemInfo = GetVariableObject("_root."$MCName);
	itemType = itemInfo.GetObject("Item_Type");
	itemName = itemInfo.GetObject("Display_Name");
	itemDescription = itemInfo.GetObject("Item_Description");

	itemType.SetString("text",container[slot].Properties.ItemType);
	itemName.SetString("text",container[slot].Properties.ItemName);
	
	description = "";
	
	//Check Item Passives
	for (i = 0; i < container[slot].PassiveSpellList.Length; i++)
	{
		passiveSpellType = container[slot].PassiveSpellList[i].PassiveSpellName;
		switch (passiveSpellType)
		{
		case Multishot:
			description $= "PASSIVE SPELL: Multishot\n";
			description $= "Creates " $ container[slot].PassiveSpellList[i].MultishotValue $ " copies of a projectile spell\n";
			break;
		case Chaos:
			description $= "PASSIVE SPELL: Chaos\n";
			description $= "Alters a spell to use 1-999 damage\n";
			description $= "Unknown affect on other equipped passives\n";
			break;
		case Storm:
			description $= "PASSIVE SPELL: Storm\n";
			description $= "Causes " $ container[slot].PassiveSpellList[i].MulticastValue $ " projectiles to rain down in an area near the player\n";
			break;
		}
	}

	//Check Item Spells
	for (i = 0; i < container[slot].SpellList.Length; i++)
	{
		spellType = container[slot].SpellList[i].SpellName;
		switch(spellType)
		{
			case Fireball:
				description $= "SPELL: " $ container[slot].SpellList[i].SpellName $ "\n";
				description $= "Sends a fireball out for " $ container[slot].SpellList[i].SpellDamageMin $ "-" $ container[slot].SpellList[i].SpellDamageMax $ " damage\n";
				description $= "-" $ container[slot].ManaCost $ " Mana\n";
				break;
			case Poisonball:
				description $= "SPELL: " $ container[slot].SpellList[i].SpellName $ "\n";
				description $= "Sends a slow moving poisonball out for " $ container[slot].SpellList[i].SpellDamageMin $ "-" $ container[slot].SpellList[i].SpellDamageMax $ " damage\n";
				description $= "-" $ container[slot].ManaCost $ " Mana\n";
				break;
			case Heal:
				description $= "SPELL: " $ container[slot].SpellList[i].SpellName $ "\n";
				description $= "A beam of light heals for " $ container[slot].SpellList[i].SpellDamageMin $ "-" $ container[slot].SpellList[i].SpellDamageMax $ " health\n";
				description $= "-" $ container[slot].ManaCost $ " Mana\n";
				break;
			case Lightning:
				description $= "SPELL: " $ container[slot].SpellList[i].SpellName $ "\n";
				description $= "Emits a bolt of lightning for " $ container[slot].SpellList[i].SpellDamageMin $ "-" $ container[slot].SpellList[i].SpellDamageMax $ " damage\n";
				description $= "-" $ container[slot].ManaCost $ " Mana\n";
				break;
			case Curse:
				description $= "SPELL: " $ container[slot].SpellList[i].SpellName $ "\n";
				description $= "Curses enemies in an area, slowing them and applying the undead status effect.\n";
				description $= "-" $ container[slot].ManaCost $ " Mana\n";
				break;
		}
	}

	//Check Item Stat Bonuses
	for (i = 0; i < container[slot].BonusList.Length; i++)
	{
		bonusType = container[slot].BonusList[i].PropertyName;
		description $= "BONUSES:\n";
		switch (bonusType)
		{
			case MaxHealthBonus:
				description $= "+" $ round(container[slot].BonusList[i].Value) $ " to Max Health \n";
				break;
			case AttackSpeedBonus:
				description $= "+" $ round(container[slot].BonusList[i].Value) $ " to Attack Speed \n";
				break;
			case MovementSpeedBonus:
				description $= "+" $ round(container[slot].BonusList[i].Value) $ " to Move Speed \n";
				break;
			case HealthRegenFlatBonus:
				description $= "+" $ round(container[slot].BonusList[i].Value) $ " to Health Regen \n";
				break;
			case ManaRegenFlatBonus:
				description $= "+" $ round(container[slot].BonusList[i].Value) $ " to Mana Regen \n";
				break;
			case MaxManaBonus:
				description $= "+" $ round(container[slot].BonusList[i].Value) $ " to Max Mana \n";
				break;
		}
	}

	itemDescription.SetString("text",description);
}

/* Event:
 * CheckForEmptySlot(int slot)
 * Description:
 * This event checks if the inventory slot selected in scaleform is empty or if it contains 
 * an item, then calls the Drag function in actionscript.
 */
event CheckForEmptySlot(int slot)
{
	local MyPawn Player1;
	Player1 = MyPawn(GetPC().Pawn);

	if (Player1.TSInventoryManager.InventoryContainer[slot].Class != class'TS_Empty')
	{
		CallDrag(slot);
	}
}

/* Event:
 * CheckForEmptyPassiveSlot(int slot)
 * Description:
 * This event checks if the passive slot selected in scaleform is empty or if it contains 
 * an item, then calls the Drag function in actionscript.
 */
event CheckForEmptyPassiveSlot(int slot)
{
	local MyPawn Player1;
	Player1 = MyPawn(GetPC().Pawn);

	if (Player1.TSInventoryManager.PassivesContainer[slot].Class != class'TS_Empty')
	{
		CallDragPassive(slot);
	}
}

/* Event:
 * CheckForEmptyActiveSlot(int slot)
 * Description:
 * This event checks if the active slot selected in scaleform is empty or if it contains 
 * an item, then calls the Drag function in actionscript.
 */
event CheckForEmptyActiveSlot(int slot)
{
	local MyPawn Player1;
	Player1 = MyPawn(GetPC().Pawn);

	if (Player1.TSInventoryManager.ActivesContainer[slot].Class != class'TS_Empty')
	{
		CallDragActive(slot);
	}
}

/* Function:
 * CallOpenInfo(int slot)
 * Description:
 * This function calls the actionscript function OpenInfoInventory, which opens the info display
 * for a particular item.
 */
function CallOpenInfo(int slot)
{
	ActionScriptVoid("OpenInfoInventory");
}

/* Function:
 * CallOpenPassiveInfo(int slot)
 * Description:
 * This function calls the actionscript function OpenInfoPassive, which opens the info display
 * for a particular item.
 */
function CallOpenPassiveInfo(int slot)
{
	ActionScriptVoid("OpenInfoPassive");
}

/* Function:
 * CallOpenActiveInfo(int slot)
 * Description:
 * This function calls the actionscript function OpenInfoActive, which opens the info display
 * for a particular item.
 */
function CallOpenActiveInfo(int slot)
{
	ActionScriptVoid("OpenInfoActive");
}

/* Function:
 * CallOpenPassiveInfo(int slot)
 * Description:
 * This function calls the actionscript function DragPassive, which begins dragging the 
 * specified item along with the cursor.
 */
function callDragPassive(int slot)
{
	ActionScriptVoid("DragPassive");
}

/* Function:
 * CallOpenActiveInfo(int slot)
 * Description:
 * This function calls the actionscript function DragActive, which begins dragging the 
 * specified item along with the cursor.
 */
function callDragActive(int slot)
{
	ActionScriptVoid("DragActive");
}

/* Function:
 * CallDrag(int slot)
 * Description:
 * This function calls the actionscript function Drag, which begins dragging the 
 * specified item along with the cursor.
 */
function CallDrag(int slot)
{
	ActionScriptVoid("Drag");
}

/* Event:
 * SetDupeDrag(string MCName, int slot, string slotType)
 * Description:
 * This function updates the movieclip to display the correct item for drag and drop.
 * If the slot is empty, nothing happens.
 */
event SetDupeDrag(string MCName, int slot, string slotType)
{
	local GFxObject drag;
	local MyPawn Player1;
	local array<TS_Items> container;

	Player1 = MyPawn(GetPC().Pawn);

	switch (slotType)
	{
		case "Inventory":
			container = Player1.TSInventoryManager.InventoryContainer;
			break;
		case "Passives":
			container = Player1.TSInventoryManager.PassivesContainer;
			break;
		case "Actives":
			container = Player1.TSInventoryManager.ActivesContainer;
			break;
	}

	if (container[slot] != none)
	{
		drag = GetVariableObject("_root."$MCName);
		drag.GotoAndStop(container[slot].Properties.ItemIcon);
	}
}

/* Event:
 * SwitchInventorySlots(int slot1, int slot2)
 * Description:
 * This function switches the contents of 2 inventory slots.
 */
event SwitchInventorySlots(int slot1, int slot2)
{
	local MyPawn Player1;
	
	Player1 = MyPawn(GetPC().Pawn);
	Player1.TSInventoryManager.SwitchInventorySlots(slot1, slot2);
}

/* Event:
 * SwitchPassiveSlots(int slot1, int slot2)
 * Description:
 * This function switches the contents of 2 passive slots.
 */
event SwitchPassiveSlots(int slot1, int slot2)
{
	local MyPawn Player1;
	
	Player1 = MyPawn(GetPC().Pawn);
	Player1.TSInventoryManager.SwitchPassiveSlots(slot1, slot2);
}

/* Event:
 * SwitchActiveSlots(int slot1, int slot2)
 * Description:
 * This function switches the contents of 2 active slots.
 */
event SwitchActiveSlots(int slot1, int slot2)
{
	local MyPawn Player1;
	
	Player1 = MyPawn(GetPC().Pawn);
	Player1.TSInventoryManager.SwitchActiveSlots(slot1, slot2);
}

/* Event:
 * SwitchInventoryWithPassiveSlots(int PassiveSlot, int InventorySlot)
 * Description:
 * This function switches the contents of 1 passive slot with 1 inventory slot.
 */
event SwitchInventoryWithPassiveSlots(int PassiveSlot, int InventorySlot)
{
	local MyPawn Player1;
	
	Player1 = MyPawn(GetPC().Pawn);
	Player1.TSInventoryManager.SwitchPassiveWithInventory(PassiveSlot, InventorySlot);
}

/* Event:
 * SwitchInventoryWithActiveSlots(int ActiveSlot, int InventorySlot)
 * Description:
 * This function switches the contents of 1 active slot with 1 inventory slot.
 */
event SwitchInventoryWithActiveSlots(int ActiveSlot, int InventorySlot)
{
	local MyPawn Player1;
	
	Player1 = MyPawn(GetPC().Pawn);
	Player1.TSInventoryManager.SwitchActiveWithInventory(ActiveSlot, InventorySlot);
}

/* Function:
 * float RoundFloat(float number)
 * Description:
 * This function rounds floats to 2 decimal places.
 */
function float RoundFloat(float number)
{
	return float((int(number * 100)) / 100);
}

event CloseInventory()
{
	ConsoleCommand("ToggleInventoryMenu");
}

DefaultProperties
{
	bEnableGammaCorrection = False
	bIgnoreMouseInput = false
	bDisplayWithHudOff=true
	//bAllowInput=TRUE
	//bAllowFocus=TRUE
	//bCaptureInput=true
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_InventoryMenu'
}
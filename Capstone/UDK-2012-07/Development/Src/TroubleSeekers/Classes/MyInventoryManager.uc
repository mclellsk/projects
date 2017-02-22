class MyInventoryManager extends Actor;

//Array of Inventory Slots
var array<TS_Items> InventoryContainer;
//Array of Passive Slots
var array<TS_Items> PassivesContainer;
//Array of Active Slots
var array<TS_Items> ActivesContainer;

//Current Inventory Item
var TS_Items InventoryItem;

//Max Inventory Size
var int InventoryContainerSize;
//Max Item Size Per Stack (i.e consumables)
var int InventoryItemStackSize;
//Max Passive Size
var int PassivesContainerSize;
//Max Active Size
var int ActivesContainerSize;

//Inventory Change
var bool HasInventoryChanged;

/* Event:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned. Sets default values of various container sizes.
 * Also initializes the slots of each container to be empty (i.e. TS_Empty).
 */
simulated event PostBeginPlay()
{
	`log("TSITEM: Inventory Loaded");
	super.PostBeginPlay();
	InventoryContainerSize = 24;
	InventoryItemStackSize = 99;
	PassivesContainerSize = 5;
	ActivesContainerSize = 5;

	InitializeSlots();
}

/* Function:
 * InitializeSlots()
 * Description:
 * Initializes all the slots in each container to be identified as empty by setting the item
 * type to TS_Empty.
 */
function InitializeSlots()
{
	local int i;
	local TS_Items EmptySlot;

	for (i = 0; i < InventoryContainerSize; i++)
	{
		EmptySlot = Spawn(class'TS_Empty');
		EmptySlot.Initialize();
		InventoryContainer.AddItem(EmptySlot);
	}

	for (i = 0; i < PassivesContainerSize; i++)
	{
		EmptySlot = Spawn(class'TS_Empty');
		EmptySlot.Initialize();
		PassivesContainer.AddItem(EmptySlot);
	}

	for (i = 0; i < ActivesContainerSize; i++)
	{
		EmptySlot = Spawn(class'TS_Empty');
		EmptySlot.Initialize();
		ActivesContainer.AddItem(EmptySlot);
	}

	HasInventoryChanged = true;
}

/* Function:
 * int AddInventoryItem(TS_Items ItemToCheck, int AmountToAdd)
 * Description:
 * This function adds an item to the player inventory.
 * If the current inventory size is smaller than the max inventory size, return amount of item remaining if all items could not be added.
 */
function int AddInventoryItem(TS_Items ItemToCheck, int AmountToAdd)
{
	local int i;
	local int RemainingAmountToAdd;

	`log("TSITEM: Adding To Inventory");
	if (AmountToAdd > 0)
	{
		for (i = 0; i < InventoryContainer.Length; i++)
		{
			//Is item already in inventory
			if (InventoryContainer[i].Class == ItemToCheck.Class)
			{
				//Is item stackable
				if (InventoryContainer[i].Properties.isStackable)
				{
					//Is stack not full
					if (!IsStackFull(InventoryContainer[i]))
					{
						//If stack is not full, add the amount required to fill the stack, apply recursion to check inventory again
						//Check to see if the AmountToAdd is greater than the difference in the size of the stack and the max stack size
						if (AmountToAdd > (InventoryItemStackSize - InventoryContainer[i].Properties.StackAmount))
						{
							InventoryContainer[i].Properties.StackAmount += (InventoryItemStackSize - InventoryContainer[i].Properties.StackAmount);
							RemainingAmountToAdd = AmountToAdd - (InventoryItemStackSize - InventoryContainer[i].Properties.StackAmount);
							AddInventoryItem(ItemToCheck, RemainingAmountToAdd);
							break;
						}
						else
						{
							InventoryContainer[i].Properties.StackAmount += AmountToAdd;
							`log("TSITEM: Finished adding item");
							HasInventoryChanged = true;
							return 0;
						}
					}
				}
			}
		}

		//If after check for item is complete and all items are full
		//Attempt to add a new instance of the item to the inventory

		//Is inventory not full
		if (!IsInventoryFull())
		{
			WorldInfo.Game.Broadcast(self, "Inventory is not full");
			//Add instance of item to inventory
			for (i = 0; i < InventoryContainer.Length; i++)
			{
				if (InventoryContainer[i].Class == class'TS_Empty')
				{
					InventoryContainer[i] = ItemToCheck;
					break;
				}
			}
			//WorldInfo.Game.Broadcast(self, "InventoryContainer[0]");
			//WorldInfo.Game.Broadcast(self, string(InventoryContainer[0].Properties.AddToMaxHealth));
			RemainingAmountToAdd = ItemToCheck.Properties.StackAmount - 1;
			AddInventoryItem(ItemToCheck, RemainingAmountToAdd);
		}
		else
		{
			`log("TSITEM: Remaining amount in item");
			HasInventoryChanged = true;
			return AmountToAdd;
		}
	}
	else
	{
		`log("TSITEM: Finished adding item");
		HasInventoryChanged = true;
		return 0;
	}
}

/* Function:
 * bool IsInventoryFull()
 * Description:
 * This function checks the inventory size and returns a bool depending on whether the inventory is full or not.
 */
function bool IsInventoryFull()
{
	local int i;
	
	for (i = 0; i < InventoryContainer.Length; i++)
	{
		if (InventoryContainer[i].Class == class'TS_Empty')
		{
			return false;
		}
	}
	
	return true;
}

/* Function:
 * bool IsSlotFull(int slot)
 * Description:
 * This function checks the specified passive slot for occupancy.
 */
function bool IsSlotFull(int slot)
{
	if (PassivesContainer[slot] != none)
	{
		return true;
	}
	else
		return false;
}

/* Function:
 * SwitchInventorySlots(int slot1, int slot2)
 * Description:
 * This function switches the contents of 2 slots in the inventory container.
 */
function SwitchInventorySlots(int slot1, int slot2)
{
	local TS_Items TempItem1;
	local TS_Items TempItem2;
	
	TempItem1 = InventoryContainer[slot1];
	TempItem2 = InventoryContainer[slot2];
	
	InventoryContainer[slot1] = TempItem2;
	InventoryContainer[slot2] = TempItem1;
}

/* Function:
 * SwitchPassiveSlots(int slot1, int slot2)
 * Description:
 * This function switches the contents of 2 slots in the passive container.
 */
function SwitchPassiveSlots(int slot1, int slot2)
{
	local TS_Items TempItem1;
	local TS_Items TempItem2;
	
	TempItem1 = PassivesContainer[slot1];
	TempItem2 = PassivesContainer[slot2];
	
	PassivesContainer[slot1] = TempItem2;
	PassivesContainer[slot2] = TempItem1;

	HasInventoryChanged = true;
}

/* Function:
 * SwitchActiveSlots(int slot1, int slot2)
 * Description:
 * This function switches the contents of 2 slots in the active container.
 */
function SwitchActiveSlots(int slot1, int slot2)
{
	local TS_Items TempItem1;
	local TS_Items TempItem2;
	
	TempItem1 = ActivesContainer[slot1];
	TempItem2 = ActivesContainer[slot2];
	
	ActivesContainer[slot1] = TempItem2;
	ActivesContainer[slot2] = TempItem1;

	HasInventoryChanged = true;
}

/* Function:
 * SwitchPassiveWithInventory(int PassiveSlot, int InventorySlot)
 * Description:
 * This function switches the contents of 1 passive slot and 1 inventory slot.
 */
function SwitchPassiveWithInventory(int PassiveSlot, int InventorySlot)
{
	local TS_Items TempItem1;
	local TS_Items TempItem2;
	
	TempItem1 = PassivesContainer[PassiveSlot];
	TempItem2 = InventoryContainer[InventorySlot];

	//Checks to see that the item switched into the passive slot is a passive tablet
	if (TempItem2.Properties.ItemType == "Passive" || TempItem2.Class == Class'TS_Empty')
	{
		PassivesContainer[PassiveSlot] = TempItem2;
		InventoryContainer[InventorySlot] = TempItem1;
		HasInventoryChanged = true;
	}
}

/* Function:
 * SwitchActiveWithInventory(int ActiveSlot, int InventorySlot)
 * Description:
 * This function switches the contents of 1 active slot and 1 inventory slot.
 */
function SwitchActiveWithInventory(int ActiveSlot, int InventorySlot)
{
	local TS_Items TempItem1;
	local TS_Items TempItem2;
	
	TempItem1 = ActivesContainer[ActiveSlot];
	TempItem2 = InventoryContainer[InventorySlot];
	
	//Checks to see that the item switched into the active slot is an active tablet
	if (TempItem2.Properties.ItemType == "Active" || TempItem2.Class == Class'TS_Empty')
	{
		ActivesContainer[ActiveSlot] = TempItem2;
		InventoryContainer[InventorySlot] = TempItem1;
		HasInventoryChanged = true;
	}
}

/* Function:
 * bool IsStackFull(TS_Items ItemToCheck)
 * Description:
 * This function checks to see if a stackable item's stack is full.
 */
function bool IsStackFull(TS_Items ItemToCheck)
{
	if (ItemToCheck.Properties.isStackable)
	{
		if (ItemToCheck.Properties.StackAmount < InventoryItemStackSize)
		{
			return false;
		}
		else
			return true;
	}
	else
	{
		return true;
	}
}

/* Function:
 * TS_Items RemoveInventoryItem(int slot, int AmountToRemove)
 * Description:
 * This function removes (AmountToRemove) number of items located in the designated Inventory (slot) number
 * and returns the item located in the slot with the amount removed. This is useful if you want to transfer
 * items between slots.
 */
function TS_Items RemoveInventoryItem(int slot, int AmountToRemove)
{
	local TS_Items TempItem;

	if (InventoryContainer[slot].Class != class'TS_Empty')
	{
		TempItem = InventoryContainer[slot];
		if (InventoryContainer[slot].Properties.StackAmount < AmountToRemove)
		{
			InventoryContainer.Remove(slot, InventoryContainer[slot].Properties.StackAmount);
			HasInventoryChanged = true;
			return TempItem;
		}
		else
		{
			InventoryContainer.Remove(slot, AmountToRemove);
			TempItem.Properties.StackAmount = AmountToRemove;
			HasInventoryChanged = true;
			return TempItem;
		}
	}
}

DefaultProperties
{
}

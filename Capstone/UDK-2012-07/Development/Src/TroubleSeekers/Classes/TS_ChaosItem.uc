class TS_ChaosItem extends TS_Items placeable;

/* Function:
 * Initialize()
 * Description:
 * This function initializes the properties of the current item.
 * These include mesh (not functional yet, there is only one default world mesh), icon,
 * item type, and name, as well as passives to apply, actives to grant, status effects to apply with cast.
 */
function Initialize()
{
	Super.Initialize();
	
	//Add passive spell to list of passives
	passive.PassiveSpellName = Chaos;
	PassiveSpellList.AddItem(passive);

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Chaos";
	Properties.ItemType = "Passive";
	Properties.ItemName = "Tablet of Chaos";
}

DefaultProperties
{
}

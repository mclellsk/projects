class TS_StormItem extends TS_Items placeable;

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
	passive.PassiveSpellName = Storm;
	passive.AreaOfEffectRange = 200;
	passive.MulticastValue = GenerateValue(25, 6, 10);
	PassiveSpellList.AddItem(passive);

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Storm";
	Properties.ItemType = "Passive";
	Properties.ItemName = "Tablet of Storm";
}

DefaultProperties
{
}

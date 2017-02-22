class TS_Empty extends TS_Items placeable;

/* Function:
 * Initialize()
 * Description:
 * This function initializes the properties of the current item.
 * These include mesh (not functional yet, there is only one default world mesh), icon,
 * item type, and name, as well as passives to apply, actives to grant, status effects to apply with cast.
 */
function Initialize()
{
	//This item represents an EMPTY slot
	Super.Initialize();
	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
}

DefaultProperties
{
}
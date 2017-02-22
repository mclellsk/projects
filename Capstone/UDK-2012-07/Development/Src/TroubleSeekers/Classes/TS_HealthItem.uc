class TS_HealthItem extends TS_Items placeable;

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
	`log("TSITEM: Health item spawned");

	//Add bonus to list of bonuses
	bonus.PropertyName = MaxHealthBonus;
	bonus.Value = GenerateValue(40, 20, 100);
	BonusList.AddItem(bonus);

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Health";
	Properties.ItemType = "Passive";
	Properties.ItemName = "Tablet of Vitality";
}

DefaultProperties
{
}
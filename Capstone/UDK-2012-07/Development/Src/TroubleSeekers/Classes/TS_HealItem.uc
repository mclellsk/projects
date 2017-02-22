class TS_HealItem extends TS_Items;

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

	//Add spell to list of spells
	spell.SpellName = Heal;
	spell.SpellDamageMax = GenerateValue(30, 50, 100);
	spell.SpellDamageMin = GenerateValue(30, 20, 50);
	spell.SpellDamageRadius = 0;
	spell.SpellProjectileMaxSpeed = 4000;
	spell.SpellProjectileSpeed = 4000;
	spell.MyDamageType = Class'TS_StatusEffect_Holy';
	SpellList.AddItem(spell);

	ManaCost = 10;

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Heal";
	Properties.ItemType = "Active";
	Properties.ItemName = "Tablet of Heal";
}

DefaultProperties
{
}

class TS_PoisonballItem extends TS_Items placeable;

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
	spell.SpellName = Poisonball;
	spell.SpellDamageMax = GenerateValue(30, 30, 50);
	spell.SpellDamageMin = GenerateValue(30, 20, 30);
	spell.SpellDamageRadius = 200;
	spell.SpellProjectileMaxSpeed = 1000;
	spell.SpellProjectileSpeed = 800;
	spell.MyDamageType = Class'TS_StatusEffect_Poisoned';
	SpellList.AddItem(spell);

	//Add StatusEffects to list of status effects
	effect.StatusEffect = Effect_Poison;
	effect.Damage = GenerateValue(20, 5, 8);
	effect.Lifetime = GenerateValue(20, 6, 10);
	StatusEffectList.AddItem(effect);

	ManaCost = 10;

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Poisonball";
	Properties.ItemType = "Active";
	Properties.ItemName = "Tablet of Poison";
}

DefaultProperties
{
}

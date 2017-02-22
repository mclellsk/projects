class TS_FireballItem extends TS_Items placeable;

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
	spell.SpellName = Fireball;
	spell.SpellDamageMax = GenerateValue(30, 50, 100);
	spell.SpellDamageMin = GenerateValue(30, 20, 50);
	spell.SpellDamageRadius = 100;
	spell.SpellProjectileMaxSpeed = 3000;
	spell.SpellProjectileSpeed = 2000;
	spell.MyDamageType = Class'TS_StatusEffect_Burning';
	SpellList.AddItem(spell);

	//Add StatusEffects to list of status effects
	effect.StatusEffect = Effect_Burn;
	effect.Damage = GenerateValue(30, 5, 10);
	effect.Lifetime = GenerateValue(30, 3, 5);
	StatusEffectList.AddItem(effect);

	ManaCost = 10;

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Fireball";
	Properties.ItemType = "Active";
	Properties.ItemName = "Tablet of Flame";
}

DefaultProperties
{
}
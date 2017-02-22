class TS_CurseItem extends TS_Items placeable;

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
	spell.SpellName = Curse;
	spell.Range = GenerateValue(10, 100, 200);
	spell.SpellDamageRadius = 100;
	spell.SpellProjectileMaxSpeed = 4000;
	spell.SpellProjectileSpeed = 4000;
	spell.SpellDamageMax = GenerateValue(10, 10, 20);
	spell.SpellDamageMin = GenerateValue(10, 5, 10);
	spell.MyDamageType = Class'TS_StatusEffect_Zombie';
	SpellList.AddItem(spell);

	//Add StatusEffects to list of status effects
	effect.StatusEffect = Effect_Zombie;
	effect.Speed = Generatevalue(10, -250, -300);
	effect.Lifetime = GenerateValue(30, 5, 8);
	StatusEffectList.AddItem(effect);

	//Mana cost per cast
	ManaCost = 10;

	Properties.ItemMeshName = "UPK_Weapons.sword_mesh";
	Properties.ItemIcon = "Zombie";
	Properties.ItemType = "Active";
	Properties.ItemName = "Tablet of Zombification";
}

DefaultProperties
{
}
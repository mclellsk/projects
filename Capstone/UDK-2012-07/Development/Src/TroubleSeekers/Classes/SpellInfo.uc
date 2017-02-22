class SpellInfo extends Actor;

/* Enumerate:
 * SpellNames
 * Description:
 * Contains all the possible active spell names. If new actives are created,
 * this list needs to be appended.
 */
enum SpellNames
{
	Fireball,
	Poisonball,
	Heal,
	Lightning,
	Curse
};

//Name of the spell
var SpellNames SpellName;
//Area of effect damage
var float SpellDamageRadius;
//Max Damage of spell
var int SpellDamageMax;
//Min Damage of spell
var int SpellDamageMin;
//Speed of the projectile
var float SpellProjectileSpeed; //default is 2000
//Max speed of the projectile
var float SpellProjectileMaxSpeed; //default is 2000
//Range Maximum
var float Range;
//If set to true, the collision radius will be larger
var bool bWideCheck;
var float CheckRadius;
//If set, an actor will be tracked by this projectile
var actor SeekTarget;
//Spell damage type
var class<DamageType> MyDamageType;

DefaultProperties
{
}

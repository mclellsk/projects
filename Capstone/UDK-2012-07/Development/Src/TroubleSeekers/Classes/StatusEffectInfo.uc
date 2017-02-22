class StatusEffectInfo extends Actor;

/* Enumerate:
 * StatusEffectTypes
 * Description:
 * Contains all the possible status effect names. If new status effects are created,
 * this list needs to be appended.
 */
enum StatusEffectTypes
{
	Effect_Burn,
	Effect_Poison,
	Effect_Zombie
};

//Status Effect Name
var StatusEffectTypes StatusEffect;

/* If more properties are possible for status effects,
 * then the variables to be accessed need to be declared here.
 */

//Lifetime of Status Effect (duration)
var int Lifetime;
//Status Effect Damage
var int Damage;
//Status Effect Heal
var int Heal;
//Status Effect Slow
var float Speed;

DefaultProperties
{
}

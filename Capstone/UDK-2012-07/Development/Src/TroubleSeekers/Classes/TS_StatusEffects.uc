class TS_StatusEffects extends Actor;

//Damage caused by status effect
var int Damage;
//Speed bonus/debuff by status effect
var float Speed;
//Number of seconds to keep status effect on
var int Count;
//Check to see if status effect is applied to target
var bool Applied;
//Hit location
var Vector HitLocation;
//Damage type of status effect
var class<DamageType> StatusDamageType;
//Status effect owner (so kills from the status effect count towards the instigator)
var Controller Instigator;
//Status effect associated with status effect
var ParticleSystemComponent ParticleEffect;

/* Function:
 * ResetValues()
 * Description:
 * This function resets the values of the status effect to be inactive.
 */
function ResetValues()
{
	Damage = 0;
	Speed = 0;
	Count = 0;
	Applied = false;
	ParticleEffect.DeactivateSystem();
	ParticleEffect = None;
}

DefaultProperties
{
	Damage = 0;
	Count = 0;
	Speed = 0;
	Applied = false;
}

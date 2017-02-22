class TS_Projectile extends UTProjectile;

//Burn status effect for use (if necessary)
var TS_StatusEffects Burn;
//Poison status effect for use (if necessary)
var TS_StatusEffects Poison;
//Zombie status effect for use (if necessary)
var TS_StatusEffects Zombie;

/* Event:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned. Initializes the burn, poison and zombie status effects.
 * If more status effects are created, they need to be added here so that all projectiles
 * have access to potentially use these status effects.
 */
event PostBeginPlay()
{
	Burn = Spawn(class'TS_StatusEffects');
	Poison = Spawn(class'TS_StatusEffects');
	Zombie = Spawn(class'TS_StatusEffects');
	super.PostBeginPlay();
	PlaySound(SpawnSound);
}

function Explode(Vector HitLocation, Vector HitNormal)
{
	PlaySound(ImpactSound);
}

/* Function:
 * int GenerateValue(int QualityPercentage, int QualityMin, int QualityMax)
 * Description:
 * This function generates a random value from qualitymin to qualitymax based on the qualitypercentage.
 * A higher quality percentage gives a better chance of generating a value closer to the upper limit.
 */
function int GenerateValue(int QualityPercentage, int QualityMin, int QualityMax)
{
	local int scale;
	local int roll;
	local float percent;
	local int scaledMin, scaledMax;
	local int value;

	roll = Rand(100);
	if (roll >= QualityPercentage && roll <= 100)
	{
		scale = (QualityMax - QualityMin);
		percent = (roll/100);
		scaledMin = percent*scale;
		value = Clamp(Rand(scale), scaledMin, scale);
		value = value + QualityMin;
	}
	else
	{
		scale = (QualityMax - QualityMin);
		percent = (roll)/100;
		scaledMax = percent*scale;
		value = Clamp(Rand(scaledMax), 0, scaledMax);
		value = value + QualityMin;
	}

	return value;
}

DefaultProperties
{
}

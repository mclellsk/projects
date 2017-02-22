class TS_StatusEffect_Zombie extends DamageType;

DefaultProperties
{
	bCausedByWorld = false;		//this damage was caused by the world (falling off level, into lava, etc)
	bExtraMomentumZ = 0;		// Add extra Z to momentum on walking pawns to throw them up into the air

	KDamageImpulse = 0;			// magnitude of impulse applied to KActor due to this damage type.
	KDeathVel = 0;				// How fast ragdoll moves upon death
	KDeathUpKick = 0;			// Amount of upwards kick ragdolls get when they die

	/** Size of impulse to apply when doing radial damage. */
	RadialDamageImpulse = 0;

	/** When applying radial impulses, whether to treat as impulse or velocity change. */
	bRadialDamageVelChange = 0;
}
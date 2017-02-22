class TS_Fireball extends TS_Projectile;

/* Function:
 * ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
 * Description:
 * Called when projectile touches an actor. Function overrides UTProjectile function.
 */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (DamageRadius > 0.0)
	{
		Explode( HitLocation, HitNormal );
	}
	else
	{
		Other.TakeDamage(Damage,InstigatorController,HitLocation,MomentumTransfer * Normal(Velocity), MyDamageType,, self);
		Shutdown();
	}

	super.ProcessTouch(Other, HitLocation, HitNormal);
}

/* Function:
 * Explode(vector HitLocation, vector HitNormal)
 * Description:
 * Called when projectile explodes, applying explosion effects and handling area of effect damage. Function overrides UTProjectile function.
 */
simulated function Explode(vector HitLocation, vector HitNormal)
{
	if (Damage>0 && DamageRadius>0)
	{
		if ( Role == ROLE_Authority )
			MakeNoise(1.0);
		if ( !bShuttingDown )
		{
			ProjectileHurtRadius(HitLocation, HitNormal );
		}
	}
	SpawnExplosionEffects(HitLocation, HitNormal);

	super.Explode(HitLocation, HitNormal);
	ShutDown();
}

/* Function:
 * ProjectileHurtRadius( vector HurtOrigin, vector HitNormal)
 * Description:
 * Handles area of effect damage. Function overrides UTProjectile function.
 */
simulated function bool ProjectileHurtRadius( vector HurtOrigin, vector HitNormal)
{
	local vector AltOrigin, TraceHitLocation, TraceHitNormal;
	local Actor TraceHitActor;

	// early out if already in the middle of hurt radius
	if ( bHurtEntry )
		return false;

	AltOrigin = HurtOrigin;

	if ( (ImpactedActor != None) && ImpactedActor.bWorldGeometry )
	{
		// try to adjust hit position out from hit location if hit world geometry
		AltOrigin = HurtOrigin + 2.0 * class'Pawn'.Default.MaxStepHeight * HitNormal;
		TraceHitActor = Trace(TraceHitLocation, TraceHitNormal, AltOrigin, HurtOrigin, false,,,TRACEFLAG_Bullet);
		if ( TraceHitActor == None )
		{
			// go half way if hit nothing
			AltOrigin = HurtOrigin + class'Pawn'.Default.MaxStepHeight * HitNormal;
		}
		else
		{
			AltOrigin = HurtOrigin + 0.5*(TraceHitLocation - HurtOrigin);
		}
	}

	return HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, AltOrigin);
}

/* Function:
 * bool HurtRadius(float DamageAmount,float InDamageRadius,class<DamageType> DamageType,float Momentum,vector HurtOrigin,
 * optional actor IgnoredActor,optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,optional bool bDoFullDamage)
 * Description:
 * Handles area of effect damage. Function overrides UTProjectile function.
 */
simulated function bool HurtRadius
(   
	float DamageAmount,
	float InDamageRadius,
	class<DamageType> DamageType,
	float Momentum,
	vector HurtOrigin,
	optional actor IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool bDoFullDamage
)
{
	local bool bCausedDamage, bResult;

	if ( bHurtEntry )
		return false;

	bCausedDamage = false;
	if (InstigatedByController == None)
	{
		InstigatedByController = InstigatorController;
	}

	// if ImpactedActor is set, we actually want to give it full damage, and then let him be ignored by super.HurtRadius()
	if ( (ImpactedActor != None) && (ImpactedActor != self))
	{
		ImpactedActor.TakeRadiusDamage(InstigatedByController, DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, true, self);
		bCausedDamage = ImpactedActor.bProjTarget;
	}

	bResult = HurtRadiusParent(DamageAmount, InDamageRadius, DamageType, Momentum, HurtOrigin, ImpactedActor, InstigatedByController, bDoFullDamage);
	return ( bResult || bCausedDamage );
}

/* Function:
 * bool HurtRadiusParent(float DamageAmount,float InDamageRadius,class<DamageType> DamageType,float Momentum,vector HurtOrigin,
 * optional actor IgnoredActor,optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,optional bool bDoFullDamage)
 * Description:
 * Handles area of effect damage. This function is used in place of the Actor.HurtRadius function. This allows the code to prevent instigator from being a victim (in the victim check).
 */
simulated function bool HurtRadiusParent
(
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	optional Actor		IgnoredActor,
	optional Controller InstigatedByController = Instigator != None ? Instigator.Controller : None,
	optional bool       bDoFullDamage
)
{
	local Actor	Victim;
	local bool bCausedDamage;
	local TraceHitInfo HitInfo;
	local StaticMeshComponent HitComponent;
	local KActorFromStatic NewKActor;

	// Prevent HurtRadius() from being reentrant.
	if ( bHurtEntry )
		return false;

	bHurtEntry = true;
	bCausedDamage = false;
	foreach VisibleCollidingActors( class'Actor', Victim, DamageRadius, HurtOrigin,,,,, HitInfo )
	{
		if ( Victim.bWorldGeometry )
		{
			// check if it can become dynamic
			// @TODO note that if using StaticMeshCollectionActor (e.g. on Consoles), only one component is returned.  Would need to do additional octree radius check to find more components, if desired
			HitComponent = StaticMeshComponent(HitInfo.HitComponent);
			if ( (HitComponent != None) && HitComponent.CanBecomeDynamic() )
			{
				NewKActor = class'KActorFromStatic'.Static.MakeDynamic(HitComponent);
				if ( NewKActor != None )
				{
					Victim = NewKActor;
				}
			}
		}
		//Prevents instigator from being a victim
		if ( !Victim.bWorldGeometry && (Victim != self) && (Victim != IgnoredActor) && (Victim.bCanBeDamaged || Victim.bProjTarget)) //&& (Victim != Instigator))
		{
			Victim.TakeRadiusDamage(InstigatedByController, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bDoFullDamage, self);
			bCausedDamage = bCausedDamage || Victim.bProjTarget;
		}
	}
	bHurtEntry = false;
	return bCausedDamage;
}

DefaultProperties
{
	Begin Object Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
	End Object
	CollisionComponent=CollisionCylinder
	CylinderComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	ProjFlightTemplate=ParticleSystem'UPK_Props.Fireball_Moving';
    ProjExplosionTemplate=ParticleSystem'UPK_Props.Explosion';
	SpawnSound=SoundCue'UPK_Sounds.Fireball_Cue';
	ImpactSound=SoundCue'UPK_Sounds.Explosion_Cue';
	//AmbientSound;		// The sound that is played looped.
	//ExplosionSound;	// The sound that is played when it explodes
	bWaitForEffects = true;
	bBlockedByInstigator=false;

	//Knockback
	MomentumTransfer = 25000;
}

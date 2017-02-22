class TS_Pawn extends UTPawn abstract dependsOn(PassiveSpellInfo, StatusEffectInfo, SpellInfo);

//Player property related to Mana Regen (holds the decimals truncated)
var float FractionalRegenMana;
//Player property related to Health Regen (holds the decimals truncated)
var float FractionalRegenHealth;
//Player property related to Current Health Regen per Second
var float RegenHealthPerSec;
//Player property related to Current Mana Regen per Second
var float RegenManaPerSec;
//Player property related to the Base Health Regen Per Second
var float BaseRegenHealthPerSec;
//Player property related to the Base Mana Regen Per Second
var float BaseRegenManaPerSec;
//Player property related to the Base Move Speed
var float BaseMoveSpeed;
//Player property related to the Base Attack Speed
var float BaseAttackSpeed;
//Player property related to the Current Critical Strike Chance (grants Critical Strike Damage Bonus)
var float CriticalChance;
//Player property related to the Base Critical Strike Chance
var float BaseCriticalChance;
//Player property related to the Base Max Health
var int BaseHealthMax;
//Player property related to the Base Max Mana
var int BaseManaMax;
//Player property related to the Current Max Mana
var int ManaMax;
//Player property related to the Current Available Mana
var int Mana;

//Conversation Array
var array<int> Conversations;
//Current Conversation Index
var int ConversationIndex;
//Bool identifying whether a pawn can be talked to
var bool bConverse;
//Pawn ID
var int PawnID;
//Pawn Name
var string PawnName;

//Status effect variable which controls the properties of the current Burn effect applied to the player.
var TS_StatusEffects Burn;
//Status effect variable which controls the properties of the current Poison effect applied to the player.
var TS_StatusEffects Poison;
//Status effect variable which controls the properties of the current Zombie effect applied to the player.
var TS_StatusEffects Zombie;

//Holds the number of casts left for the current spell use (with Storm passive). 
//Overwrites the previous number of casts if a new spell that uses this variable is used.
//TODO: This should be separated so that it is spell dependant.
var array<int> RemainingCasts;

//Different status effects that can be applied to the player
enum StatusEffects 
{
    isBurning,
    isPoisoned,
    isZombified
};

//List of status effects currently affecting the player
var array<StatusEffects> statusEffectsContainer;

var const Name SwordHandSocketName; //Nathan's variables
var AnimNodePlayCustomAnim SwingAnim;

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp) //Nathan's event
{
    super.PostInitAnimTree(SkelComp);

    if (SkelComp == Mesh)
    {
        SwingAnim = AnimNodePlayCustomAnim(SkelComp.FindAnimNode('SwingCustomAnim'));
    }
}

/* Function:
 * RemoveStatusEffect(StatusEffects effect)
 * Description:
 * This function removes a status effect from the array of effects currently 
 * affecting the player.
 */
function RemoveStatusEffect(StatusEffects effect)
{
    statusEffectsContainer.RemoveItem(effect);
}

/* Event:
 * PostBeginPlay()
 * Description:
 * Called after actor is spawned. Sets default values of player stats.
 */
event PostBeginPlay()
{
    local int i;

    super.PostBeginPlay();

    for (i = 0; i < 5; i++)
    {
        RemainingCasts.AddItem(0);
    }

    //Store Default Stats
    BaseHealthMax = self.HealthMax;
    BaseMoveSpeed = self.GroundSpeed;
    BaseAttackSpeed = self.FireRateMultiplier;
    BaseManaMax = 100;
    ManaMax = BaseManaMax;
    Mana = ManaMax;
    FractionalRegenMana = 0;
    FractionalRegenHealth = 0;
    BaseRegenHealthPerSec = 1;
    BaseRegenManaPerSec = 1;
    RegenHealthPerSec = BaseRegenHealthPerSec;
    RegenManaPerSec = BaseRegenManaPerSec;
    BaseCriticalChance = 0;
    CriticalChance = BaseCriticalChance;

    //Initialize the status effects that can potentially affect the player
    Burn = Spawn(Class'TS_StatusEffects');
    Poison = Spawn(Class'TS_StatusEffects');
    Zombie = Spawn(Class'TS_StatusEffects');

    //Start the timer that activates certain effects every 1 second
    //Calls PerSecondEffects()
    SetTimer(1, true, 'PerSecondEffects');
}

/* Function:
 * PerSecondEffects()
 * Description:
 * This function calls all other functions that occur on a 
 * per second basis, controlled by the timer function.
 */
function PerSecondEffects()
{
    UpdateHealthPerSec();
    UpdateManaPerSec();
    UpdateEffectsPerSec();
}

/* Function:
 * UpdateHealthPerSec()
 * Description:
 * This function updates the value of the pawn's current health. Applies regen effects
 * on the current health value. Does not apply fractions to increase the pawn's health, holds
 * those truncated fractions until the value is at least equal to 1, then adds the whole number integer
 * to the pawn's health, again truncating the fraction leftover.
 */
function UpdateHealthPerSec()
{
    local float tempHealthPerSec;
    
    //Get the decimal in the per sec value
    tempHealthPerSec = RegenHealthPerSec - int(RegenHealthPerSec);
    
    if (tempHealthPerSec > 0)
    {
        if (FractionalRegenHealth + tempHealthPerSec <= 1)
        {
            FractionalRegenHealth += tempHealthPerSec;
        }
        else
        {
            FractionalRegenHealth -= 1;
            if (self.Health + 1 <= self.HealthMax)
                self.Health += 1;
        }
    }

    if (self.Health + int(RegenHealthPerSec) <= self.HealthMax)
        self.Health += int(RegenHealthPerSec);
}

/* Function:
 * UpdateManaPerSec()
 * Description:
 * This function updates the value of the pawn's current mana. Applies regen effects
 * on the current mana value. Does not apply fractions to increase the pawn's mana, holds
 * those truncated fractions until the value is at least equal to 1, then adds the whole number integer
 * to the pawn's mana, again truncating the fraction leftover.
 */
function UpdateManaPerSec()
{
    local float tempManaPerSec;
    
    //Get the decimal in the per sec value
    tempManaPerSec = RegenManaPerSec - int(RegenManaPerSec);
    
    if (tempManaPerSec > 0)
    {
        if (FractionalRegenMana + tempManaPerSec <= 1)
        {
            FractionalRegenMana += tempManaPerSec;
        }
        else
        {
            FractionalRegenMana -= 1;
            if (self.Mana + 1 <= self.ManaMax)
                self.Mana += 1;
        }
    }

    if (self.Mana + int(RegenManaPerSec) <= self.ManaMax)
        self.Mana += int(RegenManaPerSec);
}

/* Function:
 * UpdateEffectsPerSec()
 * Description:
 * This function updates the current status effects applied to the player.
 * Includes damage over time and other effects that occur while the player is effected (i.e. slowdown)
 */
function UpdateEffectsPerSec()
{
    local int i;
    local StatusEffects effect;

    for (i = 0; i < statusEffectsContainer.Length; i++)
    {
        effect = statusEffectsContainer[i];
        switch (effect)
        {
            case isBurning:
                BurnOverTime();
                break;
            case isPoisoned:
                PoisonOverTime();
                break;
            case isZombified:
                ZombieOverTime();
                break;
        }
    }
}

/* Function:
 * UpdateUpdateStatusEffectParticleSystems()
 * Description:
 * This function updates the particle effects that should be applied to the pawn while
 * under the effect of a status effect.
 */
function UpdateStatusEffectParticleSystems()
{
    local int i;
    local StatusEffects effect;

    for (i = 0; i < statusEffectsContainer.Length; i++)
    {
        effect = statusEffectsContainer[i];
        switch (effect)
        {
            case isBurning:
                if (Burn.ParticleEffect == None)
                    Burn.ParticleEffect = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'UPK_Props.Fire', self.Location, , self);
                break;
            case isPoisoned:
                if (Poison.ParticleEffect == None)
                    Poison.ParticleEffect = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'UPK_Props.Poison_Cloud', self.Location, , self);
                break;
            case isZombified:
                if (Zombie.ParticleEffect == None)
                    Zombie.ParticleEffect = WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'UPK_Props.Zombie_Haunting', self.Location, , self);
                break;
        }
    }
}

/* Event:
 * Tick(float DeltaTime)
 * Description:
 * Event that occurs once per game tick. This event calls the 
 * particle system update every game update, to ensure that the particle systems display 
 * appropriately.
 */
simulated event Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    UpdateStatusEffectParticleSystems();
}

/* Event:
 * TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> TypeOfDamage, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
 * Description:
 * Event that occurs when the pawn takes damage from any source. Applies on hit effects depending on the TypeOfDamage received.
 */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> TypeOfDamage, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
    //Float Damage
    if (EventInstigator.Class == Class'MyPlayerController')
    {
        MyPawn(EventInstigator.Pawn).CreateFloatDmg(self.Location, "-"$string(Damage));
    }

    switch (TypeOfDamage)
    {
        case Class'TS_StatusEffect_Burning':
            if (statusEffectsContainer.Find(isBurning) == -1)
            {
                statusEffectsContainer.AddItem(isBurning);
            }
            if (DamageCauser.IsA('TS_Projectile'))
            {
                if ((TS_Projectile(DamageCauser).Burn.Damage) > (Burn.Damage))
                {
                    Burn.Damage = TS_Projectile(DamageCauser).Burn.Damage;
                    Burn.Count = TS_Projectile(DamageCauser).Burn.Count;
                    Burn.StatusDamageType = TypeOfDamage;
                    Burn.HitLocation = HitLocation;
                    Burn.Instigator = EventInstigator;
                }
            }
            break;
        case Class'TS_StatusEffect_Poisoned':
            if (statusEffectsContainer.Find(isPoisoned) == -1)
            {
                statusEffectsContainer.AddItem(isPoisoned);
            }
            if (DamageCauser.IsA('TS_Projectile'))
            {
                if ((TS_Projectile(DamageCauser).Poison.Damage) > (Poison.Damage))
                {
                    Poison.Damage = TS_Projectile(DamageCauser).Poison.Damage;
                    Poison.Count = TS_Projectile(DamageCauser).Poison.Count;
                    Poison.StatusDamageType = TypeOfDamage;
                    Poison.HitLocation = HitLocation;
                    Poison.Instigator = EventInstigator;
                }
            }
            break;
        case Class'TS_StatusEffect_Zombie':
            if (statusEffectsContainer.Find(isZombified) == -1)
            {
                statusEffectsContainer.AddItem(isZombified);
            }
            if (DamageCauser.IsA('TS_Projectile'))
            {
                if ((TS_Projectile(DamageCauser).Zombie.Speed) < (Zombie.Speed))
                {
                    Zombie.Speed = TS_Projectile(DamageCauser).Zombie.Speed;
                    Zombie.Count = TS_Projectile(DamageCauser).Zombie.Count;
                    Zombie.StatusDamageType = TypeOfDamage;
                    Zombie.HitLocation = HitLocation;
                    Zombie.Instigator = EventInstigator;
                }
            }
            break;
    }
    Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, TypeOfDamage, HitInfo, DamageCauser);
}

/* Function:
 * BurnOverTime()
 * Description:
 * This function applies burn damage per second, decrements the counter after every tick of 
 * burn damage is applied for that second.
 */
function BurnOverTime()
{
    self.Health -= (Burn.Damage);
    if(self.Health <= 0)
    {
        self.Died(Burn.Instigator,Burn.StatusDamageType,Burn.HitLocation);
    }
    Burn.Count--;

    if (Burn.Count <= 0)
    {
        RemoveStatusEffect(isBurning);
        Burn.ResetValues();
    }
}

/* Function:
 * PoisonOverTime()
 * Description:
 * This function applies poison damage per second, decrements the counter after every tick of 
 * poison damage is applied for that second.
 */
function PoisonOverTime()
{
    self.Health -= (Poison.Damage);
    if(self.Health <= 0)
    {
        self.Died(Poison.Instigator,Poison.StatusDamageType,Poison.HitLocation);
    }
    Poison.Count--;

    if (Poison.Count <= 0)
    {
        RemoveStatusEffect(isPoisoned);
        Poison.ResetValues();
    }
}

/* Function:
 * ZombieOverTime()
 * Description:
 * This function applies zombie speed effects per second, decrements the counter after every tick of 
 * zombie damage is applied for that second.
 */
function ZombieOverTime()
{
    if (!Zombie.Applied)
    {
        //Value of speed should be declared negative in the Zombie property
        //so adding Zombie.Speed would reduce the speed.
        self.GroundSpeed += Zombie.Speed;
        Zombie.Applied = true;
    }
    Zombie.Count--;

    if (Zombie.Count <= 0)
    {
        self.GroundSpeed -= Zombie.Speed;
        RemoveStatusEffect(isZombified);
        Zombie.ResetValues();
    }
}

/* Function:
 * UseSpellFireball(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
 * Description:
 * This function controls the behaviour of the fireball spell. It takes in the inherited properties of the spell (SpellInfo) used (i.e. damage, range, etc)
 * and the passive ability associated with the item slot (passive slot 1 -> active slot 1), the status effects associated with the spell (StatusEffectInfo) and
 * the global passive abilities that may affect the spell as well.
 * Behaviour:
 * Default - Fires projectile directly infront of the pawn.
 * Multishot - Fires multiple projectiles infront of the pawn within an arc range.
 * Storm - Fires projectiles downwards in an area around the player (random).
 * Chaos - Randomizes damage from 1-999 (IMBA).
 */
function UseSpellFireball(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
{
    local PassiveSpellNames passiveSpellName;
    local array<StatusEffectInfo> statusEffectList;
    local class<DamageType> TypeOfDamage;
    local array<TS_Fireball> projectiles;
    local bool isStormLinked;

    //Spell damage
    local int damage;
    //Number of spell projectiles
    local int numberOfProjectiles;
    //Area of effect cast range (if necessary)
    local int areaOfEffectRange;
    //Spell spread range infront of the pawn
    local int arc;
    //Separation distance between projectiles in multi-projectile casts
    local int divisor;
    
    local int currentYawPos;
    local float projectilePosX, projectilePosY;

    local Rotator newRotation;
    local Vector newLocation;

    local int i,j,k;

    //Default properties
    arc = 5461; //30 degrees
    currentYawPos = self.Rotation.Yaw - (arc/2);
    damage = GenerateValue(50, currentSpell.SpellDamageMin, currentSpell.SpellDamageMax);
    numberOfProjectiles = 1;
    projectilePosX = 0;
    projectilePosY = 0;
    areaOfEffectRange = 0;
    isStormLinked = false;

    //Effect checks on spell
    if (passives.Length > 0)
    {
        for (i = 0; i < passives.Length; i++)
        {
            passiveSpellName = passives[i].PassiveSpellName;
            
            //Damage Attribute
            if (passiveSpellName == Chaos) //This is a linked passive
            {
                damage = GenerateValue(10, 1, 999);
            }

            //Number of Projectiles Attribute
            if (passiveSpellName == Multishot) //This is a linked passive
            {
                if (isChaosEquipped(passivesEquipped)) //This is a global passive TODO:Clean up the handling of global passives
                {
                    numberOfProjectiles = GenerateValue(30, 1, passives[i].MultishotValue + 4);
                }
                else
                {
                    numberOfProjectiles = passives[i].MultishotValue;
                }
            }

            //Area of Effect Range Attribute
            if (passiveSpellName == Storm)
            {
                isStormLinked = true;
                areaOfEffectRange = passives[i].AreaOfEffectRange;
            }
        }
    }

    //Storm passive effect on spell
    if (isStormLinked)
    {
        while (projectilePosX == 0)
            projectilePosX = GenerateValue(50, -areaOfEffectRange, areaOfEffectRange);
        while (projectilePosY == 0)
            projectilePosY = GenerateValue(50, -areaOfEffectRange, areaOfEffectRange);
        newLocation = vect(0, 0, 600);
        newLocation.X = projectilePosX;
        newLocation.Y = projectilePosY;
    }

    //This loop contains the bulk behaviour of the projectile, it iterates through the number of projectiles to be fired
    //per cast, NOT the same as multicast (which treats each projectile uniquely i.e. variable damage).
    for (j = 0; j < numberOfProjectiles; j++)
    {
        projectiles.AddItem(self.Spawn(class'TS_Fireball', self, 'None', self.Location));
        projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
        //Status Effects 
        //TODO: Separate the status effect check/update from the spell code.
        TypeOfDamage = currentSpell.MyDamageType;
        statusEffectList = effects;
        switch (TypeOfDamage)
        {
            case class'TS_StatusEffect_Burning':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Burn)
                    {
                        projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                        projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
            case class'TS_StatusEffect_Poisoned':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Poison)
                    {
                        projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                        projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
        }

        //Update projectile properties based on SpellInfo
        projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
        projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
        projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
        projectiles[j].Damage = damage;
        projectiles[j].bWideCheck = true;
        projectiles[j].CheckRadius = currentSpell.CheckRadius;

        //This set of checks controls the multishot behaviour, correctly spacing the distance between the projectiles.
        //It updates the rotation direction for each individual projectile based on the number of projectiles (if odd number
        //greater than 1, the projectiles will fire one directly infront of the pawn, while an even number will not, leaving a gap).
        if (numberOfProjectiles == 1) //one
        {
            newRotation = self.Rotation;
            if (isStormLinked)
            {
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(self.Location + newLocation);
                projectiles[j].init(Vector(newRotation));   
            }
            else
            {
                projectiles[j].init(Vector(newRotation));
            }
        }
        else if (numberOfProjectiles % 2 == 0) //even
        {
            divisor = arc/numberOfProjectiles;
        
            if (j == numberOfProjectiles/2)
                currentYawPos = self.Rotation.Yaw;

            newRotation = self.Rotation;
            newRotation.Yaw = currentYawPos + (divisor) * j;
            projectiles[j].SetRotation(newRotation);
            if (isStormLinked)
            {
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(self.Location + newLocation);
                projectiles[j].SetRotation(newRotation);
                projectiles[j].init(Vector(projectiles[j].Rotation));   
            }
            else
            {
                projectiles[j].init(Vector(newRotation));
            }
        }
        else if (numberOfProjectiles % 2 == 1) //odd
        {
            divisor = arc/(numberOfProjectiles - 1);
            newRotation = self.Rotation;
            newRotation.Yaw = currentYawPos + (divisor) * j;
            projectiles[j].SetRotation(newRotation);
            if (isStormLinked)
            {
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(self.Location + newLocation);
                projectiles[j].SetRotation(newRotation);
                projectiles[j].init(Vector(newRotation));   
            }
            else
            {
                projectiles[j].init(Vector(newRotation));
            }
        }
    }
}

/* Function:
 * UseSpellPoisonball(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
 * Description:
 * This function controls the behaviour of the poisonball spell. It takes in the inherited properties of the spell (SpellInfo) used (i.e. damage, range, etc)
 * and the passive ability associated with the item slot (passive slot 1 -> active slot 1), the status effects associated with the spell (StatusEffectInfo) and
 * the global passive abilities that may affect the spell as well.
 * Behaviour:
 * Default - Fires projectile directly infront of the pawn.
 * Multishot - Fires multiple projectiles infront of the pawn within an arc range.
 * Storm - Fires projectiles downwards in an area around the player (random).
 * Chaos - Randomizes damage from 1-999 (IMBA).
 */
function UseSpellPoisonball(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
{
    local PassiveSpellNames passiveSpellName;
    local array<StatusEffectInfo> statusEffectList;
    local class<DamageType> TypeOfDamage;
    local array<TS_Poisonball> projectiles;
    local bool isStormLinked;

    //Spell damage
    local int damage;
    //Number of spell projectiles
    local int numberOfProjectiles;
    //Area of effect cast range (if necessary)
    local int areaOfEffectRange;
    //Spell spread range infront of the pawn
    local int arc;
    //Separation distance between projectiles in multi-projectile casts
    local int divisor;

    local int currentYawPos;
    local float projectilePosX, projectilePosY;

    local Rotator newRotation;
    local Vector newLocation;

    local int i,j,k;

    //default attributes
    arc = 5461; //30 degrees
    currentYawPos = self.Rotation.Yaw - (arc/2);
    damage = GenerateValue(50, currentSpell.SpellDamageMin, currentSpell.SpellDamageMax);
    numberOfProjectiles = 1;
    projectilePosX = 0;
    projectilePosY = 0;
    areaOfEffectRange = 0;
    isStormLinked = false;

    //Effect checks on spell
    if (passives.Length > 0)
    {
        for (i = 0; i < passives.Length; i++)
        {
            passiveSpellName = passives[i].PassiveSpellName;
            
            //Damage Attribute
            if (passiveSpellName == Chaos) //This is a linked passive
            {
                damage = GenerateValue(10, 1, 999);
            }

            //Number of Projectiles Attribute
            if (passiveSpellName == Multishot) //This is a linked passive
            {
                if (isChaosEquipped(passivesEquipped)) //This is a global passive TODO:Clean up the handling of global passives
                {
                    numberOfProjectiles = GenerateValue(30, 1, passives[i].MultishotValue + 4);
                }
                else
                {
                    numberOfProjectiles = passives[i].MultishotValue;
                }
            }

            //Area of Effect Range Attribute
            if (passiveSpellName == Storm)
            {
                isStormLinked = true;
                areaOfEffectRange = passives[i].AreaOfEffectRange;
            }
        }
    }

    //Storm passive effect on spell
    if (isStormLinked)
    {
        while (projectilePosX == 0)
            projectilePosX = GenerateValue(50, -areaOfEffectRange, areaOfEffectRange);
        while (projectilePosY == 0)
            projectilePosY = GenerateValue(50, -areaOfEffectRange, areaOfEffectRange);
        newLocation = vect(0, 0, 600);
        newLocation.X = projectilePosX;
        newLocation.Y = projectilePosY;
    }

    //This loop contains the bulk behaviour of the projectile, it iterates through the number of projectiles to be fired
    //per cast, NOT the same as multicast (which treats each projectile uniquely i.e. variable damage).
    for (j = 0; j < numberOfProjectiles; j++)
    {
        projectiles.AddItem(self.Spawn(class'TS_Poisonball', self, 'None', self.Location));
        projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
        //Status Effects 
        //TODO: Separate the status effect check/update from the spell code.
        TypeOfDamage = currentSpell.MyDamageType;
        statusEffectList = effects;
        switch (TypeOfDamage)
        {
            case class'TS_StatusEffect_Burning':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Burn)
                    {
                        projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                        projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
            case class'TS_StatusEffect_Poisoned':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Poison)
                    {
                        projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                        projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
        }

        //Update projectile properties based on SpellInfo
        projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
        projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
        projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
        projectiles[j].Damage = damage;
        projectiles[j].bWideCheck = true;
        projectiles[j].CheckRadius = currentSpell.CheckRadius;

        //This set of checks controls the multishot behaviour, correctly spacing the distance between the projectiles.
        //It updates the rotation direction for each individual projectile based on the number of projectiles (if odd number
        //greater than 1, the projectiles will fire one directly infront of the pawn, while an even number will not, leaving a gap).
        if (numberOfProjectiles == 1) //one
        {
            newRotation = self.Rotation;
            if (isStormLinked)
            {
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(self.Location + newLocation);
                projectiles[j].init(Vector(newRotation));   
            }
            else
            {
                projectiles[j].init(Vector(newRotation));
            }
        }
        else if (numberOfProjectiles % 2 == 0) //even
        {
            divisor = arc/numberOfProjectiles;
        
            if (j == numberOfProjectiles/2)
                currentYawPos = self.Rotation.Yaw;

            newRotation = self.Rotation;
            newRotation.Yaw = currentYawPos + (divisor) * j;
            projectiles[j].SetRotation(newRotation);

            if (isStormLinked)
            {
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(self.Location + newLocation);
                projectiles[j].SetRotation(newRotation);
                projectiles[j].init(Vector(projectiles[j].Rotation));   
            }
            else
            {
                projectiles[j].init(Vector(newRotation));
            }
        }
        else if (numberOfProjectiles % 2 == 1) //odd
        {
            divisor = arc/(numberOfProjectiles - 1);
            newRotation = self.Rotation;
            newRotation.Yaw = currentYawPos + (divisor) * j;
            projectiles[j].SetRotation(newRotation);
            if (isStormLinked)
            {
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(self.Location + newLocation);
                projectiles[j].SetRotation(newRotation);
                projectiles[j].init(Vector(newRotation));   
            }
            else
            {
                projectiles[j].init(Vector(newRotation));
            }
        }
    }
}

/* Function:
 * UseSpellHeal(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
 * Description:
 * This function controls the behaviour of the heal spell. It takes in the inherited properties of the spell (SpellInfo) used (i.e. damage, range, etc)
 * and the passive ability associated with the item slot (passive slot 1 -> active slot 1), the status effects associated with the spell (StatusEffectInfo) and
 * the global passive abilities that may affect the spell as well.
 * Behaviour:
 * Default - Heals self.
 * Multishot - Multi-heal on self.
 * Storm - Multi-heal based on the number of multi-cast to enemies on screen (auto-target)
 * Chaos - Randomizes damage from 1-999 (IMBA).
 */
function UseSpellHeal(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
{
    local PassiveSpellNames passiveSpellName;
    local array<StatusEffectInfo> statusEffectList;
    local class<DamageType> TypeOfDamage;
    local array<TS_Heal> projectiles;
    local bool isStormLinked;

    //Heal amount
    local int heal;
    //Number of spell projectiles
    local int numberOfProjectiles;

    //Auto-target enemies
    local TS_Pawn Victim;
    local TraceHitInfo HitInfo;

    //Area of effect cast range (if necessary)
    local int areaOfEffectRange;
    //Spell spread range infront of the pawn
    local int arc;
    //Separation distance between projectiles in multi-projectile casts
    local int divisor;

    local int currentYawPos;
    local float projectilePosX, projectilePosY;

    local Rotator newRotation;
    local Vector newLocation;

    local int i,j,k;

    //default attributes
    arc = 5461; //30 degrees
    currentYawPos = self.Rotation.Yaw - (arc/2);
    heal = GenerateValue(50, currentSpell.SpellDamageMin, currentSpell.SpellDamageMax);
    numberOfProjectiles = 1;
    projectilePosX = 0;
    projectilePosY = 0;
    areaOfEffectRange = 0;
    isStormLinked = false;

    //Effect checks on spell
    if (passives.Length > 0)
    {
        for (i = 0; i < passives.Length; i++)
        {
            passiveSpellName = passives[i].PassiveSpellName;
            
            //Damage Attribute
            if (passiveSpellName == Chaos) //This is a linked passive
            {
                heal = GenerateValue(10, 1, 999);
            }

            //Number of Projectiles Attribute
            if (passiveSpellName == Multishot) //This is a linked passive
            {
            }

            //Area of Effect Range Attribute
            if (passiveSpellName == Storm)
            {
                isStormLinked = true;
                if (isChaosEquipped(passivesEquipped)) //This is a global passive TODO:Clean up the handling of global passives
                {
                    numberOfProjectiles = GenerateValue(30, 1, passives[i].MulticastValue + 4);
                }
                else
                {
                    numberOfProjectiles = passives[i].MulticastValue;
                }
                areaOfEffectRange = passives[i].AreaOfEffectRange;
            }
        }
    }

    //Behavioural effect from linked passives
    //Storm passive effect on spell, behaves differently than other projectiles.
    //It auto-targets a number of enemies on screen, and applies healing effects within a 
    //range on screen (works with zombie status effect to cause damage).
    if (isStormLinked)
    {
        j = 0;
        foreach VisibleCollidingActors( class'TS_Pawn',Victim,1000,,,,,,HitInfo )
        {
            if (numberOfProjectiles > 0)
            {
                if (!Victim.bWorldGeometry && (Victim.bCanBeDamaged || Victim.bProjTarget))
                {
                    numberOfProjectiles--;
                    projectiles.AddItem(self.Spawn(class'TS_Heal', self, 'None', vect(0,0,600)));
                    projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
                    //Status Effects 
                    //TODO: Separate the status effect check/update from the spell code.
                    TypeOfDamage = currentSpell.MyDamageType;
                    statusEffectList = effects;
                    switch (TypeOfDamage)
                    {
                        case class'TS_StatusEffect_Burning':
                            for (k = 0; k < statusEffectList.Length; k++)
                            {
                                if (statusEffectList[k].StatusEffect == Effect_Burn)
                                {
                                    projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                                    projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                                }
                            }
                            break;
                        case class'TS_StatusEffect_Poisoned':
                            for (k = 0; k < statusEffectList.Length; k++)
                            {
                                if (statusEffectList[k].StatusEffect == Effect_Poison)
                                {
                                    projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                                    projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                                }
                            }
                            break;
                    }

                    //Update projectile properties based on SpellInfo
                    projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
                    projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
                    projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
                    projectiles[j].Damage = heal;
                    projectiles[j].bWideCheck = true;
                    projectiles[j].CheckRadius = currentSpell.CheckRadius;

                    //Adjust direction of projectile fire
                    newLocation = vect(0, 0, 600);
                    newRotation = Victim.Rotation;
                    newRotation.Pitch -= 16383;
                    projectiles[j].SetLocation(Victim.Location + newLocation);
                    projectiles[j].init(Vector(newRotation));
                    //Tracks the target (auto-targetting)
                    projectiles[j].SeekTarget = Victim;
                    projectiles[j].BaseTrackingStrength = 1000;
                    j++;
                }
            }
        }
    }
    else //If behaviour altering passive is not applied
    {
        for (j = 0; j < numberOfProjectiles; j++)
        {
            projectiles.AddItem(self.Spawn(class'TS_Heal', self, 'None', self.Location));
            projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
            //Status Effects 
            //TODO: Separate the status effect check/update from the spell code.
            TypeOfDamage = currentSpell.MyDamageType;
            statusEffectList = effects;
            switch (TypeOfDamage)
            {
                case class'TS_StatusEffect_Burning':
                    for (k = 0; k < statusEffectList.Length; k++)
                    {
                        if (statusEffectList[k].StatusEffect == Effect_Burn)
                        {
                            projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                            projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                        }
                    }
                    break;
                case class'TS_StatusEffect_Poisoned':
                    for (k = 0; k < statusEffectList.Length; k++)
                    {
                        if (statusEffectList[k].StatusEffect == Effect_Poison)
                        {
                            projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                            projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                        }
                    }
                    break;
            }

            //Update projectile properties based on SpellInfo
            projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
            projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
            projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
            projectiles[j].Damage = heal;
            projectiles[j].bWideCheck = true;
            projectiles[j].CheckRadius = currentSpell.CheckRadius;

            //Adjust direction of projectile fire
            newLocation = vect(0, 0, 600);
            newRotation.Pitch -= 16383;
            projectiles[j].SetLocation(self.Location + newLocation);
            projectiles[j].init(Vector(newRotation));

            //Follows the target casting the spell
            projectiles[j].SeekTarget = self;
            projectiles[j].BaseTrackingStrength = 1000;
        }
    }
}

/* Function:
 * UseSpellLightning(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
 * Description:
 * This function controls the behaviour of the lightning spell. It takes in the inherited properties of the spell (SpellInfo) used (i.e. damage, range, etc)
 * and the passive ability associated with the item slot (passive slot 1 -> active slot 1), the status effects associated with the spell (StatusEffectInfo) and
 * the global passive abilities that may affect the spell as well.
 * Behaviour:
 * Default - Fires bolt infront of pawn.
 * Multishot - Auto-targets enemies on screen, does not hit the same enemy twice.
 * Storm - Fires bolt projectiles from above down onto an area around the instigator.
 * Chaos - Randomizes damage from 1-999 (IMBA).
 */
function UseSpellLightning(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
{
    local PassiveSpellNames passiveSpellName;
    local array<StatusEffectInfo> statusEffectList;
    local class<DamageType> TypeOfDamage;

    //Horizontal Projectiles behave differently than Vertical Projectiles so they need to be declared separately
    //TODO: Find a better way to do this.
    local array<TS_Lightning> projectiles;
    local array<TS_Lightning_Horizon> projectiles2;

    local bool isStormLinked;
    local bool isMultishotLinked;

    //Spell damage
    local int damage;
    //Number of spell projectiles
    local int numberOfProjectiles;

    //Auto-target enemies
    local TS_Pawn Victim;
    local TraceHitInfo HitInfo;

    //Area of effect cast range (if necessary)
    local int areaOfEffectRange;
    //Spell spread range infront of the pawn
    local int arc;
    //Separation distance between projectiles in multi-projectile casts
    local int divisor;

    local int currentYawPos;
    local float projectilePosX, projectilePosY;

    local Rotator newRotation;
    local Vector newLocation;

    local int i,j,k;

    //default attributes
    arc = 5461; //30 degrees
    currentYawPos = self.Rotation.Yaw - (arc/2);
    damage = GenerateValue(50, currentSpell.SpellDamageMin, currentSpell.SpellDamageMax);
    numberOfProjectiles = 1;
    projectilePosX = 0;
    projectilePosY = 0;
    areaOfEffectRange = 0;
    isStormLinked = false;

    //Effect checks on spell
    if (passives.Length > 0)
    {
        for (i = 0; i < passives.Length; i++)
        {
            passiveSpellName = passives[i].PassiveSpellName;
            
            //Damage Attribute
            if (passiveSpellName == Chaos) //this is a linked passive
            {
                damage = GenerateValue(10, 1, 999);
            }

            //Number of Projectiles Attribute
            if (passiveSpellName == Multishot) //this is a linked passive
            {
                isMultishotLinked = true;
                if (isChaosEquipped(passivesEquipped)) //this is a global passive
                {
                    numberOfProjectiles = GenerateValue(30, 1, passives[i].MultishotValue + 4);
                }
                else
                {
                    numberOfProjectiles = passives[i].MultishotValue;
                }
            }

            //Area of Effect Range Attribute
            if (passiveSpellName == Storm)
            {
                isStormLinked = true;
                areaOfEffectRange = passives[i].AreaOfEffectRange;
            }
        }
    }

    //Behavioural effects from linked passives
    if (isMultishotLinked)
    {
        j = 0;
        foreach VisibleCollidingActors( class'TS_Pawn',Victim,1000,,,,,,HitInfo )
        {
            if (numberOfProjectiles > 0)
            {
                //Prevents instigator from being a victim
                if (!Victim.bWorldGeometry && (Victim != self) && (Victim.bCanBeDamaged || Victim.bProjTarget))
                {
                    numberOfProjectiles--;
                    projectiles.AddItem(self.Spawn(class'TS_Lightning', self, 'None', vect(0,0,600)));
                    projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
                    //Status Effects 
                    //TODO: Separate the status effect check/update from the spell code.
                    TypeOfDamage = currentSpell.MyDamageType;
                    statusEffectList = effects;
                    switch (TypeOfDamage)
                    {
                        case class'TS_StatusEffect_Burning':
                            for (k = 0; k < statusEffectList.Length; k++)
                            {
                                if (statusEffectList[k].StatusEffect == Effect_Burn)
                                {
                                    projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                                    projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                                }
                            }
                            break;
                        case class'TS_StatusEffect_Poisoned':
                            for (k = 0; k < statusEffectList.Length; k++)
                            {
                                if (statusEffectList[k].StatusEffect == Effect_Poison)
                                {
                                    projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                                    projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                                }
                            }
                            break;
                    }

                    //Update projectile properties based on SpellInfo
                    projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
                    projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
                    projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
                    projectiles[j].Damage = damage;
                    projectiles[j].bWideCheck = true;
                    projectiles[j].CheckRadius = currentSpell.CheckRadius;

                    //Direction behaviour
                    newLocation = vect(0, 0, 600);
                    newRotation = Victim.Rotation;
                    newRotation.Pitch -= 16383;
                    projectiles[j].SetLocation(Victim.Location + newLocation);
                    projectiles[j].init(Vector(newRotation));   
                    projectiles[j].SeekTarget = Victim;
                    projectiles[j].BaseTrackingStrength = 100;
                    j++;
                }
            }
        }
    }
    else if (isStormLinked)
    {
        while (projectilePosX == 0)
            projectilePosX = GenerateValue(50, -areaOfEffectRange, areaOfEffectRange);
        while (projectilePosY == 0)
            projectilePosY = GenerateValue(50, -areaOfEffectRange, areaOfEffectRange);
        newLocation = vect(0, 0, 600);
        newLocation.X = projectilePosX;
        newLocation.Y = projectilePosY;

        projectiles.AddItem(self.Spawn(class'TS_Lightning', self, 'None', vect(0,0,600)));
        projectiles[0].MyDamageType = currentSpell.MyDamageType;
        
        //Status Effects 
        //TODO: Separate the status effect check/update from the spell code.
        TypeOfDamage = currentSpell.MyDamageType;
        statusEffectList = effects; 
        switch (TypeOfDamage)
        {
            case class'TS_StatusEffect_Burning':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Burn)
                    {
                        projectiles[0].Burn.Damage = statusEffectList[k].Damage;
                        projectiles[0].Burn.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
            case class'TS_StatusEffect_Poisoned':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Poison)
                    {
                        projectiles[0].Poison.Damage = statusEffectList[k].Damage;
                        projectiles[0].Poison.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
        }

        //Update projectile properties based on SpellInfo
        projectiles[0].Speed = currentSpell.SpellProjectileSpeed;
        projectiles[0].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
        projectiles[0].DamageRadius = currentSpell.SpellDamageRadius;
        projectiles[0].Damage = damage;
        projectiles[0].bWideCheck = true;
        projectiles[0].CheckRadius = currentSpell.CheckRadius;

        //Direction behaviour
        newRotation = self.Rotation;
        newRotation.Pitch -= 16383;
        projectiles[0].SetLocation(self.Location + newLocation);
        projectiles[0].init(Vector(newRotation));   
    }
    else
    {
        //Horizontal bolt behaviour (only for default cast)

        projectiles2.AddItem(self.Spawn(class'TS_Lightning_Horizon', self, 'None', self.Location));
        projectiles2[0].MyDamageType = currentSpell.MyDamageType;
        
        //Status Effects 
        //TODO: Separate the status effect check/update from the spell code.
        TypeOfDamage = currentSpell.MyDamageType;
        statusEffectList = effects;
        switch (TypeOfDamage)
        {
            case class'TS_StatusEffect_Burning':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Burn)
                    {
                        projectiles2[0].Burn.Damage = statusEffectList[k].Damage;
                        projectiles2[0].Burn.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
            case class'TS_StatusEffect_Poisoned':
                for (k = 0; k < statusEffectList.Length; k++)
                {
                    if (statusEffectList[k].StatusEffect == Effect_Poison)
                    {
                        projectiles2[0].Poison.Damage = statusEffectList[k].Damage;
                        projectiles2[0].Poison.Count = statusEffectList[k].Lifetime;
                    }
                }
                break;
        }

        //Update projectile properties based on SpellInfo
        projectiles2[0].Speed = currentSpell.SpellProjectileSpeed;
        projectiles2[0].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
        projectiles2[0].DamageRadius = currentSpell.SpellDamageRadius;
        projectiles2[0].Damage = damage;
        projectiles2[0].bWideCheck = true;
        projectiles2[0].CheckRadius = currentSpell.CheckRadius;
        projectiles2[0].init(Vector(self.Rotation));
    }
}

/* Function:
 * UseSpellCurse(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
 * Description:
 * This function controls the behaviour of the curse spell. It takes in the inherited properties of the spell (SpellInfo) used (i.e. damage, range, etc)
 * and the passive ability associated with the item slot (passive slot 1 -> active slot 1), the status effects associated with the spell (StatusEffectInfo) and
 * the global passive abilities that may affect the spell as well.
 * Behaviour:
 * Default - Curses self with zombie status effect (slowing the player).
 * Multishot - Curse enemies in area around the player applying zombie status effect (slowing the enemy).
 * Storm - No effect.
 * Chaos - No effect.
 * TODO: Make zombie effect increase health regen.
 */
function UseSpellCurse(SpellInfo currentSpell, array<PassiveSpellInfo> passives, array<StatusEffectInfo> effects, array<PassiveSpellInfo> passivesEquipped)
{
    local PassiveSpellNames passiveSpellName;
    local array<StatusEffectInfo> statusEffectList;
    local class<DamageType> TypeOfDamage;
    local array<TS_Curse> projectiles;

    local bool isStormLinked;
    local bool isMultishotLinked;

    //Spell damage
    local int damage;
    //Number of spell projectiles
    local int numberOfProjectiles;

    //Auto-target enemies
    local TS_Pawn Victim;
    local TraceHitInfo HitInfo;

    //Area of effect cast range (if necessary)
    local int areaOfEffectRange;
    //Spell spread range infront of the pawn
    local int arc;
    //Separation distance between projectiles in multi-projectile casts
    local int divisor;

    local int currentYawPos;
    local float projectilePosX, projectilePosY;

    local Rotator newRotation;
    local Vector newLocation;

    local int i,j,k;

    //default attributes
    arc = 5461; //30 degrees
    currentYawPos = self.Rotation.Yaw - (arc/2);
    damage = GenerateValue(50, currentSpell.SpellDamageMin, currentSpell.SpellDamageMax);
    numberOfProjectiles = 1;
    projectilePosX = 0;
    projectilePosY = 0;
    areaOfEffectRange = 0;
    isStormLinked = false;

    //Effect checks on spell
    if (passives.Length > 0)
    {
        for (i = 0; i < passives.Length; i++)
        {
            passiveSpellName = passives[i].PassiveSpellName;
            
            //Damage Attribute
            if (passiveSpellName == Chaos) //This is a linked passive
            {
                damage = GenerateValue(10, 1, 999);
            }

            //Number of Projectiles Attribute
            if (passiveSpellName == Multishot) //This is a linked passive
            {
                isMultishotLinked = true;
                if (isChaosEquipped(passivesEquipped)) //This is a global passive TODO:Clean up the handling of global passives
                {
                    numberOfProjectiles = GenerateValue(30, 1, passives[i].MultishotValue + 4);
                }
                else
                {
                    numberOfProjectiles = passives[i].MultishotValue;
                }
            }

            //Area of Effect Range Attribute
            if (passiveSpellName == Storm)
            {
                isStormLinked = true;
            }
        }
    }

    //Behavioural effects from linked passives
    if (isMultishotLinked)
    {
        j = 0;
        foreach VisibleCollidingActors( class'TS_Pawn',Victim,1000,,,,,,HitInfo )
        {
            //Prevents instigator from being a victim
            if (!Victim.bWorldGeometry && (Victim.bCanBeDamaged || Victim.bProjTarget))
            {
                projectiles.AddItem(self.Spawn(class'TS_Curse', self, 'None', vect(0,0,600)));
                projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
                //Status Effects
                //TODO: Separate the status effect check/update from the spell code.
                TypeOfDamage = currentSpell.MyDamageType;
                statusEffectList = effects;
                switch (TypeOfDamage)
                {
                    case class'TS_StatusEffect_Burning':
                        for (k = 0; k < statusEffectList.Length; k++)
                        {
                            if (statusEffectList[k].StatusEffect == Effect_Burn)
                            {
                                projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                                projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                            }
                        }
                        break;
                    case class'TS_StatusEffect_Poisoned':
                        for (k = 0; k < statusEffectList.Length; k++)
                        {
                            if (statusEffectList[k].StatusEffect == Effect_Poison)
                            {
                                projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                                projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                            }
                        }
                        break;
                    case class'TS_StatusEffect_Zombie':
                        for (k = 0; k < statusEffectList.Length; k++)
                        {
                            if (statusEffectList[k].StatusEffect == Effect_Zombie)
                            {
                                projectiles[j].Zombie.Speed = statusEffectList[k].Speed;
                                projectiles[j].Zombie.Count = statusEffectList[k].Lifetime;
                            }
                        }
                        break;
                }

                //Update projectile properties based on SpellInfo
                projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
                projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
                projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
                projectiles[j].Damage = damage;
                projectiles[j].bWideCheck = true;
                projectiles[j].CheckRadius = currentSpell.CheckRadius;

                //Directional behaviour
                newLocation = vect(0, 0, 600);
                newRotation = Victim.Rotation;
                newRotation.Pitch -= 16383;
                projectiles[j].SetLocation(Victim.Location + newLocation);
                projectiles[j].init(Vector(newRotation));   
                projectiles[j].SeekTarget = Victim;
                projectiles[j].BaseTrackingStrength = 100;
                j++;
            }
        }
    }
    else if (isStormLinked)
    {
    }
    else
    {
        for (j = 0; j < numberOfProjectiles; j++)
        {
            projectiles.AddItem(self.Spawn(class'TS_Curse', self, 'None', self.Location));
            projectiles[j].MyDamageType = currentSpell.MyDamageType;
        
            //Status Effects
            //TODO: Separate the status effect check/update from the spell code.
            TypeOfDamage = currentSpell.MyDamageType;
            statusEffectList = effects;
            switch (TypeOfDamage)
            {
                case class'TS_StatusEffect_Burning':
                    for (k = 0; k < statusEffectList.Length; k++)
                    {
                        if (statusEffectList[k].StatusEffect == Effect_Burn)
                        {
                            projectiles[j].Burn.Damage = statusEffectList[k].Damage;
                            projectiles[j].Burn.Count = statusEffectList[k].Lifetime;
                        }
                    }
                    break;
                case class'TS_StatusEffect_Poisoned':
                    for (k = 0; k < statusEffectList.Length; k++)
                    {
                        if (statusEffectList[k].StatusEffect == Effect_Poison)
                        {
                            projectiles[j].Poison.Damage = statusEffectList[k].Damage;
                            projectiles[j].Poison.Count = statusEffectList[k].Lifetime;
                        }
                    }
                    break;
                case class'TS_StatusEffect_Zombie':
                        for (k = 0; k < statusEffectList.Length; k++)
                        {
                            if (statusEffectList[k].StatusEffect == Effect_Zombie)
                            {
                                projectiles[j].Zombie.Speed = statusEffectList[k].Speed;
                                projectiles[j].Zombie.Count = statusEffectList[k].Lifetime;
                            }
                        }
                        break;
            }

            //Update projectile properties based on spell info
            projectiles[j].Speed = currentSpell.SpellProjectileSpeed;
            projectiles[j].MaxSpeed = currentSpell.SpellProjectileMaxSpeed;
            projectiles[j].DamageRadius = currentSpell.SpellDamageRadius;
            projectiles[j].Damage = damage;
            projectiles[j].bWideCheck = true;
            projectiles[j].CheckRadius = currentSpell.CheckRadius;

            //Directional behaviour
            newLocation = vect(0, 0, 600);
            newRotation.Pitch -= 16383;
            projectiles[j].SetLocation(self.Location + newLocation);
            projectiles[j].init(Vector(newRotation));

            //Follows the target casting the spell
            projectiles[j].SeekTarget = self;
            projectiles[j].BaseTrackingStrength = 1000;
        }
    }
}

//Function:
//bool isChaosEquipped(array<PassiveSpellInfo> passivesEquipped)
//Description:
//Global Passive Check for Chaos Passive
//TODO: Create a function that checks all global passives, or some other implementation
//to result in similar functionality.
function bool isChaosEquipped(array<PassiveSpellInfo> passivesEquipped)
{
    local int j;

    for (j = 0; j < passivesEquipped.Length; j++)
    {
        if (passivesEquipped[j].PassiveSpellName == Chaos)
        {
            return True;
        }
    }
}

//Function:
//int GenerateValue(int QualityPercentage, int QualityMin, int QualityMax)
//Description:
//Function to randomize integer values clamped on a scale, based on the quality percentage.
//The higher the quality percentage, the larger a chance there is at receiving a number closer
//to the upper limit of the scale (QualityMax) and vice versa.
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
    SwordHandSocketName = WeaponPoint
    bConverse = false;
}

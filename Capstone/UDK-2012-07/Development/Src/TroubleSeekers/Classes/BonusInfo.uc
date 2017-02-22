class BonusInfo extends Actor;

/* Enumerate:
 * Bonus
 * Description:
 * Contains all the possible bonuses that can affect the player
 * statistics. This list needs to be edited when new statistics are
 * added, or if new bonuses are created, then the calculation for each 
 * stat needs to be changed in the MyPawn class (which updates player stats).
 */
enum Bonus
{
	RestoreHealth,
	MaxHealthBonus,
	AttackSpeedBonus,
	MovementSpeedBonus,
	MaxManaBonus,
	ManaRegenFlatBonus,
	HealthRegenFlatBonus,
	AttackDamageBonus
};

//Bonus to apply
var Bonus PropertyName;
//Value of bonus to apply
var float Value;

DefaultProperties
{
}

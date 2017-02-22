class TS_Items extends Actor abstract dependsOn (PassiveSpellInfo);

var BonusInfo bonus;
var SpellInfo spell;
var StatusEffectInfo effect;
var PassiveSpellInfo passive;

//Stat bonuses for item
var array<BonusInfo> BonusList;
//Spells for item
var array<SpellInfo> SpellList;
//Status effects for item
var array<StatusEffectInfo> StatusEffectList;
//Passives for item
var array<PassiveSpellInfo> PassiveSpellList;

//Mana Cost of using tablet
var int ManaCost;
//String description of item
var string description;

/* Struct:
 * ItemProperties
 * Description:
 * Contains the properties of an item, such as the item name, type, icon, pickup sound, 
 * stackability and stack size.
 */
struct ItemProperties
{
	var() int StackAmount;
	var() bool isStackable;
	var() SoundCue PickUpSound;
	var() string ItemName;
	var() string ItemType;
	var() string ItemMeshName;
	var() string ItemIcon;
	var() string PickUpMessage;
};

var() ItemProperties Properties;

/* Function:
 * Initialize()
 * Description:
 * This function initializes the bonus properties, effect properties, spell properties, passive properties, and item properties.
 */
function Initialize()
{
	bonus = Spawn(class'BonusInfo');
	effect = Spawn(class'StatusEffectInfo');
	spell = Spawn(class'SpellInfo');
	passive = Spawn(class'PassiveSpellInfo');

	Properties.isStackable = false;
	Properties.StackAmount = 1;
	Properties.ItemMeshName = "Default";
	Properties.PickUpSound = None;
	Properties.ItemName = "Default";
	Properties.PickUpMessage = "Default";
	Properties.ItemIcon = "Empty";
	Properties.ItemType = "Passive";
}

/* Function:
 * int GenerateValue(int QualityPercentage, int QualityMin, int QualityMax)
 * Description:
 * Function to randomize integer values clamped on a scale, based on the quality percentage.
 * The higher the quality percentage, the larger a chance there is at receiving a number closer
 * to the upper limit of the scale (QualityMax) and vice versa.
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
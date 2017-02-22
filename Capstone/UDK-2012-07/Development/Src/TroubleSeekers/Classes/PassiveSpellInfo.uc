class PassiveSpellInfo extends Actor;

/* Enumerate:
 * PassiveSpellNames
 * Description:
 * Contains all the possible passive spell names. If new passives are created,
 * this list needs to be appended.
 */
enum PassiveSpellNames
{
	//Duplicates the spell linked to this passive by a certain value
	Multishot,
	//Changes the values of a spell linked (generally damage, speed, size, etc.)
	//Also affects other passives that are equipped (i.e. multi-shot will randomize between 2-MAX_SHOT)
	Chaos,
	//Multicast makes the spell repeat a certain number of times
	Multicast,
	//Causes the spell to rain down upon an enemy
	Storm
};

//Passive Type
var PassiveSpellNames PassiveSpellName;
//Value controlling number of projectiles
var int MultishotValue;
//Value controlling number of times spell is cast
var int MulticastValue;
//Value controlling area of effect for AOE spells
var int AreaOfEffectRange;

DefaultProperties
{
}

class TS_SubQuest extends Actor;

/* Enumerate:
 * QuestType
 * Description:
 * Contains all the possible classifications of a quest. Fetch quests require the player to pick up an item.
 * Kill quests require the player to kill a certain number of a specific type of NPC. Find quests require the player
 * to trigger a kismet block collision event.
 */
enum QuestType
{
	Fetch,
	Kill,
	Find
};

//Number of items or enemies to collect or kill.
var int QuestCount;
//Number of items or enemies currently collected or killed.
var int CurrentCount;
//Description of the quest
var string QuestDescription;
//Progress string (i.e. Killed Goats: 0/2)
var string QuestTracking;
//Type of quest
var QuestType Type;
//Target of the kill quest (if valid)
var string QuestTarget;
//Target of fetch quest (if valid)
var class<TS_Items> QuestItem;
//Quest completion bool
var bool isComplete;

DefaultProperties
{
	CurrentCount = 0;
	isComplete = false;
}

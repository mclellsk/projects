class TS_EventManager extends Actor;


/* Struct:
 * PawnsKilled
 * Description:
 * This struct holds information on the type of pawn killed, and the number of this pawn killed since the beginning of the game.
 * The struct contains the list of pawn types that are associated to this category of pawn, this allows for more dynamic structuring of pawns, class hierarchy does not need to be 
 * redone each time.
 */
struct PawnsKilled
{
	var string PawnCategory;
	var array< class<TS_Pawn> > PawnTypes;
	var int count;
};

struct Reward
{
	var bool bGiven;
	var TS_Items Reward;
};

var array<PawnsKilled> PawnsKilledList;

//Array of rewards
var array<Reward> RewardList;

//Quest Manager
var TS_QuestManager QuestManager;

/* Event:
 * PostBeginPlay()
 * Description:
 * This event initializes the quest manager for the player, and initializes all pawn types that need to be tracked.
 */
event PostBeginPlay()
{
	local PawnsKilled pawnKilled;
	local Reward reward;

	QuestManager = Spawn(class'TS_QuestManager', self);

	//Add Ratmen Category
	pawnKilled.PawnCategory = "Ratmen";
	pawnKilled.PawnTypes.AddItem(class'MyEnemy');
	pawnKilled.count = 0;
	PawnsKilledList.AddItem(pawnKilled);

	//Add Boss Category
	pawnKilled.PawnCategory = "Boss";
	pawnKilled.PawnTypes.AddItem(class'MyBoss');
	pawnKilled.count = 0;
	PawnsKilledList.AddItem(pawnKilled);

	//Add MyEnemy Category
	pawnKilled.PawnCategory = "MyEnemy";
	pawnKilled.PawnTypes.AddItem(class'MyEnemy');
	pawnKilled.count = 0;
	PawnsKilledList.AddItem(pawnKilled);

	//Add MyEnemy Category
	pawnKilled.PawnCategory = "BillyTheOld";
	pawnKilled.PawnTypes.AddItem(class'TS_Neutral_Villager_1');
	pawnKilled.count = 0;
	PawnsKilledList.AddItem(pawnKilled);

	//Add RattyMan Category
	pawnKilled.PawnCategory = "RattyMan";
	pawnKilled.PawnTypes.AddItem(class'TS_Neutral_Villager_2');
	pawnKilled.count = 0;
	PawnsKilledList.AddItem(pawnKilled);

	//Rewards

	//Reward 0 for Quest 0 - Kill 20 Dungeon Enemies
	reward.bGiven = false;
	reward.Reward = Spawn(class'TS_FireballItem');
	reward.Reward.Initialize();
	RewardList.AddItem(reward);

	//Reward for Conversation 0 - Billy The Old
	reward.bGiven = false;
	reward.Reward = Spawn(class'TS_HealthRegenItem');
	reward.Reward.Initialize();
	RewardList.AddItem(reward);

	//Reward for Quest 1 - Kill Billy the Old
	reward.bGiven = false;
	reward.Reward = Spawn(class'TS_PoisonballItem');
	reward.Reward.Initialize();
	RewardList.AddItem(reward);

	//Reward for Quest 2 - Kill 10 Ratmen
	reward.bGiven = false;
	reward.Reward = Spawn(class'TS_HealItem');
	reward.Reward.Initialize();
	RewardList.AddItem(reward);

	//Reward for Quest 3 - Kill Ratty Man
	reward.bGiven = false;
	reward.Reward = Spawn(class'TS_MultishotItem');
	reward.Reward.Initialize();
	RewardList.AddItem(reward);
}

/* Function:
 * AddKill(class<TS_Pawn> type)
 * Description:
 * This function increments the kill count of a pawn type by 1. Also updates any quests that may need to track specific type of pawn.
 * Place this function in the death function of the pawn's class, called by the player's MyPawn function.
 * Example: MyPawn(Killer.Pawn).TSEventManager.AddKill(class'MyEnemy');
 */
function AddKill(class<TS_Pawn> type)
{
	local int i, j, k;

	for (i = 0; i < PawnsKilledList.Length; i++)
	{
		k = PawnsKilledList[i].PawnTypes.Find(type);
		if (k != -1)
		{
			PawnsKilledList[i].count++;
		}
	}

	//This is not a good way of keeping count per quest, I sense an issue if multiple enemies die at the same time. Perhaps a queue for the number dead would be good here.
	for (i = 0; i < QuestManager.CurrentQuestList.Length; i++)
	{
		for (j = 0; j < QuestManager.CurrentQuestList[i].subQuests.Length; j++)
		{
			if (QuestManager.CurrentQuestList[i].subQuests[j].Type == Kill)
			{
				for (k = 0; k < PawnsKilledList.Length; k++)
				{
					if (PawnsKilledList[k].PawnCategory == QuestManager.CurrentQuestList[i].subQuests[j].QuestTarget)
					{
						if (PawnsKilledList[k].PawnTypes.Find(type) != -1)
						{
							QuestManager.CurrentQuestList[i].subQuests[j].CurrentCount++;
						}
					}
				}
			}
		}
	}
}

/* Function:
 * PostDecisionCheck()
 * Description:
 * This function checks the decisions a player makes, and immediately calls events during conversation, this may include the
 * addition of items, or quests, etc.
 */
function PostDecisionCheck()
{
	local MyPawn PlayerOwner;
	PlayerOwner = MyPawn(Owner);

	if (PlayerOwner.TSEventManager.QuestManager.IsQuestComplete(0) && !RewardList[0].bGiven)
	{
		GiveReward(0);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestComplete(1) && !RewardList[2].bGiven)
	{
		GiveReward(2);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestComplete(2) && !RewardList[3].bGiven)
	{
		GiveReward(3);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestComplete(3) && !RewardList[4].bGiven)
	{
		GiveReward(4);
	}
	if ((PlayerOwner.TSConversationManager.CheckDecision(0,2,8) || PlayerOwner.TSConversationManager.CheckDecision(0,1,4) 
		|| PlayerOwner.TSConversationManager.CheckDecision(0,0,2) || PlayerOwner.TSConversationManager.CheckDecision(0,2,7)) && !RewardList[1].bGiven)
	{
		PlayerOwner.CreateNotification("You have received an item");
		GiveReward(1);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestAvailable(0) && PlayerOwner.TSConversationManager.CheckDecision(0,6,14))
	{
		PlayerOwner.CreateNotification("You have received a quest");
		PlayerOwner.TSEventManager.QuestManager.MoveQuestToCurrent(0);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestAvailable(1) && PlayerOwner.TSConversationManager.CheckDecision(0,8,17))
	{
		PlayerOwner.CreateNotification("You have received a quest");
		PlayerOwner.TSEventManager.QuestManager.MoveQuestToCurrent(1);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestAvailable(2) && PlayerOwner.TSConversationManager.CheckDecision(2,2,5))
	{
		PlayerOwner.CreateNotification("You have received a quest");
		PlayerOwner.TSEventManager.QuestManager.MoveQuestToCurrent(2);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestAvailable(3) && PlayerOwner.TSConversationManager.CheckDecision(2, 3, 7)) //Kill ratmen
	{
		PlayerOwner.CreateNotification("You have received a quest");
		PlayerOwner.TSEventManager.QuestManager.MoveQuestToCurrent(3);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestAvailable(2) && PlayerOwner.TSConversationManager.CheckDecision(2, 7, 11))//Kill rattymen
	{
		PlayerOwner.CreateNotification("You have received a quest");
		PlayerOwner.TSEventManager.QuestManager.MoveQuestToCurrent(2);
	}
	if (PlayerOwner.TSEventManager.QuestManager.IsQuestAvailable(3) && PlayerOwner.TSConversationManager.CheckDecision(2, 7, 12))
	{
		PlayerOwner.CreateNotification("You have received a quest");
		PlayerOwner.TSEventManager.QuestManager.MoveQuestToCurrent(3);
	}
}

function GiveReward(int id)
{
	local MyPawn PlayerOwner;
	PlayerOwner = MyPawn(Owner);

	if (!RewardList[id].bGiven)
	{
		PlayerOwner.TSInventoryManager.AddInventoryItem(RewardList[id].Reward, 1);
		RewardList[id].bGiven = True;
	}
}

DefaultProperties
{
}

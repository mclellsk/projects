class TS_QuestManager extends Actor dependson(TS_SubQuest);

//Quest Manager is initialized inside Event Manager.

/* Struct:
 * QuestStructure
 * Description:
 * This struct makes up the entity which represents a quest. A quest can have many subQuests (fetch,kill,find)
 * and is represented by an id, linking multiple subQuests together.
 */
struct QuestStructure
{
	var array<TS_SubQuest> subQuests;
	var bool isComplete;
	var int questID;
	var string questName;
	var string questDescription;
};

//Quests that can be received by the player
var array<QuestStructure> AvailableQuestList;
//Quests that have been received by the player but not completed
var array<QuestStructure> CurrentQuestList;
//Quests that have been received by the player and completed
var array<QuestStructure> CompletedQuestList;

/* Event:
 * PostBeginPlay()
 * Description:
 * This is where all quests that will be available in game should be created. Switching the created quest from the 
 * available to current quest list enables the quest for completion by the player.
 */
event PostBeginPlay()
{
	local string questname;
	local string description;

	/* 
	 * QuestID: 0
	 * QuestName: Clear The Way
	 * Originator: TS_Neutral_Villager_1
	 */
	questname = "Clear The Way";
	description = "Kill 20 enemies in the dungeon.";
	//Subquest 1
	AddKillQuest(0, questname, description, "MyEnemy", 20);
	description = "";
	description $= "I've met an old man named Billy. He's been trapped down here for quite a long time, 50 years to be exact.";
	description $= " If I could just clear the way for this helpful guy, perhaps he could be brave enough to make it to the outside world.";
	AddQuestDescription(0, description, 0);

	/*
	 * QuestID: 1
	 * QuestName: Expediting The Aging Process
	 * Originator: TS_Neutral_Villager_1
	 */
	questname = "Expediting The Aging Process";
	description = "Kill Billy The Old.";
	//Subquest 1
	AddKillQuest(1, questname, description, "BillyTheOld", 1);
	description = "";
	description $= "I've met an old man named Billy. He's an annoying old geezer who can't bear to go forward through the dungeon.";
	description $= " Someone this pitiful should be put out of their misery, especially in this place... I mean seriously, he's eating live rats.";
	description $= " This dusty bag of bones is probably better off free of this torment.";
	AddQuestDescription(1, description, 0);

	/*
	 * QuestID: 2
	 * QuestName: Gnawing at the Foot of Evil
	 * Originator: TS_Neutral_Villager_2 RATTY MAN
	 */
	questname = "Gnawing at the Foot of Evil";
	description = "Kill 10 ratmen.";
	//Subquest 1
	AddKillQuest(2, questname, description, "Ratmen", 10);
	description = "";
	description $= "I've met crazy a villager who thinks that hes actually part of the rat clan. Unfortunately for the rat clan, them not being able to understand him";
	description $= " is about as bad as having him be their enemy. He asked me to thrash these rats, and I'll do it, because he's so nice. Psyche, he said there was something";
	description $= " in it for me. Perhaps I can use this reward to bolster my skill in an effort to find my friends.";
	AddQuestDescription(2, description, 0);

	/*
	 * QuestID: 3
	 * QuestName: Crawl Back Into Your Hole
	 * Originator: TS_Neutral_Villager_2 RATTY MAN
	 */
	questname = "Crawl Back Into Your Hole";
	description = "Kill Ratty Man.";
	//Subquest 1
	AddKillQuest(3, questname, description, "RattyMan", 1);
	description = "";
	description $= "I've met crazy a villager who thinks that hes actually part of the rat clan. He's been wasting my time and I've had enough of this, I need to rid myself of this nonsense.";
	description $= " He'll never confuse the tip of my blade as a gesture of good will. When this is over, perhaps I can get back on track and find my friends.";
	AddQuestDescription(3, description, 0);

	/*
	 * QuestID: 4
	 * QuestName: Crawl Back Into Your Hole
	 * Originator: TS_Neutral_Villager_2 RATTY MAN
	 */
	questname = "The Indeadable Hulk";
	description = "Kill The Hulk.";
	//Subquest 1
	AddKillQuest(4, questname, description, "Boss", 1);
	description = "";
	description $= "He probably knows where my friends have gone, first I need to find the key to the door, only then can I battle him.";
	AddQuestDescription(4, description, 0);
}

/* Function:
 * bool IsQuestComplete(int id)
 * Description:
 * This function checks to see if a quest is completed (all subquests part of that quest are complete).
 */
function bool IsQuestComplete(int id)
{
	if (CompletedQuestList.Find('questID', id) != -1)
	{
		return true;
	}
	else
		return false;
}

/* Function:
 * bool IsQuestComplete(int id)
 * Description:
 * This function checks to see if a quest is completed (all subquests part of that quest are complete).
 */
function bool IsQuestAvailable(int id)
{
	if (AvailableQuestList.Find('questID', id) != -1)
	{
		return true;
	}
	else
		return false;
}

/* Event:
 * Tick(float DeltaTime)
 * Description:
 * This function updates every game tick.
 */
simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	//Update();
}

/* Function:
 * Update()
 * Description:
 * This function calls the other functions that check the completion of subquests and the completion of quests.
 * Call subquest check before you call quest check, order matters.
 */
simulated function Update()
{
	CheckSubQuestCompletion();
	CheckQuestCompletion();
}

/* Function:
 * CheckQuestCompletion()
 * Description:
 * This function checks the completion progress of a quest.
 */
function CheckQuestCompletion()
{
	local int i, j;
	local bool isCompleted;

	for (i = 0; i < CurrentQuestList.Length; i++)
	{
		isCompleted = true;
		if (!CurrentQuestList[i].isComplete)
		{
			for (j = 0; j < CurrentQuestList[i].subQuests.Length; j++)
			{
				//If any of the subquests are not complete, this whole operation returns false
				if (!CurrentQuestList[i].subQuests[j].isComplete)
				{
					isCompleted = false;
					break;
				}
			}

			if (isCompleted)
			{
				MyPawn(Owner).CreateNotification("Quest Complete");
				CurrentQuestList[i].isComplete = true;
				CompletedQuestList.AddItem(CurrentQuestList[i]);
			}
		}
	}
}

/* Function:
 * CheckSubQuestCompletion()
 * Description:
 * This function checks the completion progress of a subquest.
 */
function CheckSubQuestCompletion()
{
	local int i, j;
	local QuestType type;

	for (i = 0; i < CurrentQuestList.Length; i++)
	{
		if (!CurrentQuestList[i].isComplete)
		{
			for (j = 0; j < CurrentQuestList[i].subQuests.Length; j++)
			{
				type = CurrentQuestList[i].subQuests[j].Type;
				switch (type)
				{
					case Fetch:
						if (CurrentQuestList[i].subQuests[j].CurrentCount >= CurrentQuestList[i].subQuests[j].QuestCount)
						{
							CurrentQuestList[i].subQuests[j].isComplete = true;
						}
						break;
					case Kill:
						if (CurrentQuestList[i].subQuests[j].CurrentCount >= CurrentQuestList[i].subQuests[j].QuestCount)
						{
							CurrentQuestList[i].subQuests[j].isComplete = true;
						}
						break;
					case Find:
						//TBA
						break;
				}
			}
		}
	}
}

/* Function:
 * MoveQuestToCurrent(int id)
 * Description:
 * This function moves quests in the available quest list to the current quest list so that they can be tracked and 
 * completed by the game.
 */
function MoveQuestToCurrent(int id)
{
	//Adds quest to current quests
	CurrentQuestList.AddItem(AvailableQuestList[AvailableQuestList.Find('questID', id)]);

	//Removes the quest from available quests
	AvailableQuestList.Remove(AvailableQuestList.Find('questID', id), 1);
}

/* Function:
 * AddQuestDescription(int questId, string description, int type)
 * Description:
 * This function updates the MAIN quest description of a quest. Can edit either available, in-progress, or complete quests.
 * 0 - available, 1 - in-progress, 2 - complete.
 */
function AddQuestDescription(int questId, string description, int type)
{
	switch (type)
	{
		case 0:
			//Available Quest
			AvailableQuestList[questId].questDescription = description;
			break;
		case 1:
			//Current Quest
			CurrentQuestList[questId].questDescription = description;
			break;
		case 2:
			//Completed Quest
			CompletedQuestList[questId].questDescription = description;
			break;
	}
}

/* Function:
 * AddKillQuest(int id, string questName, string description, class<TS_Pawn> pawnType, int count)
 * Description:
 * This function adds a kill quest to the available quest list.
 */
function AddKillQuest(int id, string questName, string description, string pawnCategory, int count)
{
	local QuestStructure quest;
	local TS_SubQuest subQuest;

	subQuest = Spawn(class'TS_SubQuest');
	subQuest.QuestDescription = description;
	subQuest.QuestTracking = "Killed: ";
	subQuest.QuestTarget = pawnCategory;
	subQuest.Type = Kill;
	subQuest.QuestCount = count;
	subQuest.isComplete = false;

	//If the quest id cannot be found, create a new instance of the quest
	//and store the subquest in that quest array entry. If the quest can be
	//found, append the list with the new quest. This allows multiple subquests
	//to be linked to the same one quest, as multiple components to be complete
	//in order to be true of completion of the quest.

	if (AvailableQuestList.Find('questID', id) == -1)
	{
		WorldInfo.Game.Broadcast(self, "Added Quest to Available");
		quest.questID = id;
		quest.questName = questName;
		quest.isComplete = false;
		quest.subQuests.AddItem(subQuest);
		AvailableQuestList.AddItem(quest);
	}
	else
	{
		WorldInfo.Game.Broadcast(self, "Added Quest to Existing");
		AvailableQuestList[AvailableQuestList.Find('questID', id)].subQuests.AddItem(subQuest);
	}
}

/* Function:
 * AddFetchQuest(int id, string questName, string description, class<TS_Items> itemType, int count)
 * Description:
 * This function adds a fetch quest to the available quest list.
 */
function AddFetchQuest(int id, string questName, string description, class<TS_Items> itemType, int count)
{
	local QuestStructure quest;
	local TS_SubQuest subQuest;

	subQuest = Spawn(class'TS_SubQuest');
	subQuest.QuestDescription = description;
	subQuest.QuestItem = itemType;
	subQuest.Type = Fetch;
	subQuest.QuestCount = count;
	subQuest.isComplete = false;

	//If the quest id cannot be found, create a new instance of the quest
	//and store the subquest in that quest array entry. If the quest can be
	//found, append the list with the new quest. This allows multiple subquests
	//to be linked to the same one quest, as multiple components to be complete
	//in order to be true of completion of the quest.

	if (AvailableQuestList.Find('questID', id) == -1)
	{
		//WorldInfo.Game.Broadcast(self, "Added Quest to Available");
		quest.questID = id;
		quest.questName = questName;
		quest.isComplete = false;
		quest.subQuests.AddItem(subQuest);
		AvailableQuestList.AddItem(quest);
	}
	else
	{
		AvailableQuestList[AvailableQuestList.Find('questID', id)].subQuests.AddItem(subQuest);
	}
}

DefaultProperties
{
}

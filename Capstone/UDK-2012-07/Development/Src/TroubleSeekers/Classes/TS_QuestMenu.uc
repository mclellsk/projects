class TS_QuestMenu extends GFxMoviePlayer;

//Root Flash Object
var GFxObject Root;
//Quest List Titles Flash Object
var GFxObject QuestList;
//Quest Descriptions Flash Object
var GFxObject Description;
//DataProvider Flash Object (contains data for Quest List)
var GFxObject DataProvider;

/* Function:
 * Initialize()
 * Description:
 * Initializes all flash objects.
 */
function Initialize()
{
	DataProvider = CreateArray();

	Root = GetVariableObject("_root");

	QuestList = Root.GetObject("QuestsLog").GetObject("QuestList");
	QuestList.SetObject("dataProvider", DataProvider);

	Description = Root.GetObject("QuestsLog").GetObject("Description");
}

/* Function:
 * TickHUD()
 * Description:
 * Update the contents of the quest list with the completed and current quests.
 */
function TickHUD()
{
	//TODO: Update Quest Log with the contents of the CompletedQuestList in the EventManager
	local int i;
	local MyPawn Player1;

	Player1 = MyPawn(GetPC().Pawn);
	for (i = 0; i < Player1.TSEventManager.QuestManager.CurrentQuestList.Length; i++)
	{
		DataProvider.SetElementString(i, Player1.TSEventManager.QuestManager.CurrentQuestList[i].questName);
	}
	QuestList.SetObject("dataProvider", DataProvider);
}

/* Event:
 * SetQuestDescription(int questId)
 * Description:
 * This function is called by Actionscript to update the contents of the description flash object when the index is selected from the
 * quest log list.
 */
event SetQuestDescription(int questId)
{
	local MyPawn Player1;
	local string text;
	local int i;
	Player1 = MyPawn(GetPC().Pawn);

	//Player1.WorldInfo.Game.Broadcast(Player1, "Quest" $ questId);

	//Main quest description
	text = Player1.TSEventManager.QuestManager.CurrentQuestList[questId].questDescription;

	//Sub quest descriptions
	for (i = 0; i < Player1.TSEventManager.QuestManager.CurrentQuestList[questId].subQuests.Length; i++)
	{
		text $= Player1.TSEventManager.QuestManager.CurrentQuestList[questId].subQuests[i].QuestDescription $ "\n";
	}

	Description.SetString("text", text);
}

event CloseQuestLog()
{
	ConsoleCommand("ToggleQuestMenu");
}

DefaultProperties
{
	bEnableGammaCorrection = False
	bIgnoreMouseInput = false
	bDisplayWithHudOff=true
	bAllowInput=TRUE
	bAllowFocus=TRUE
	bCaptureInput=true
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_QuestMenu'
}

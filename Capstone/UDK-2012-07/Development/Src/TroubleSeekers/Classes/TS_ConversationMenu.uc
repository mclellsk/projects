class TS_ConversationMenu extends GFxMoviePlayer;

//Root Flash Object
var GFxObject Root;
//Player Response List Flash Object
var GFxObject PlayerResponsesList;
//NPC Response Flash Object
var GFxObject NPCResponses;
//NPC Name Flash Object
var GFxObject NPCName;
//DataProvider Flash Object (contains data for Player Response List)
var GFxObject DataProvider;
//NPC Response Index
var int NPCResponseIndex;

/* Function:
 * Initialize()
 * Description:
 * Initializes all flash objects. This must run everytime the menu is opened, to default the npc response index back to 0 (The greeting message basically).
 */
function Initialize()
{
	Root = GetVariableObject("_root");

	PlayerResponsesList = Root.GetObject("PlayerResponses");

	NPCResponses = Root.GetObject("NPCResponse");
	NPCName = Root.GetObject("NPCName");
	NPCResponseIndex = 0;
}

/* Function:
 * TickHUD()
 * Description:
 * Update the contents of the conversation box with the current conversation player responses and npc response.
 * TODO: put the npcresponseindex into the mypawn class, add a function that updates the NPCresponseindex based on the 
 * event handler (click) from the scaleform player response.
 */
function TickHUD()
{
	local int i;
	local MyPawn Player1;
	local int StartedConversationIndex;
	local int ConversationIndex;
	local int ConversationId;
	local array<int> PlayerResponseIndices;

	Player1 = MyPawn(GetPC().Pawn);
	StartedConversationIndex = Player1.TSConversationManager.ConversationsStarted.Find('NPCId', Player1.CurrentNPC.PawnId); //The current index of conversation set between the player and NPC
	ConversationIndex = Player1.TSConversationManager.ConversationsStarted[StartedConversationIndex].ConversationIndex; //The current conversation index of the conversation set (the state of the conversation)
	ConversationId = Player1.CurrentNPC.Conversations[ConversationIndex]; //The actual ConversationID of the current conversation state (to be used to gather the data from the master conversation list)

	PlayerResponseIndices = Player1.TSConversationManager.ConversationList[ConversationId].NPCResponses[NPCResponseIndex].PlayerResponseIndices; //The indices of corresponding player responses for current NPCResponse in conversation (against master list)

	DataProvider = CreateArray();
	for (i = 0; i < PlayerResponseIndices.Length; i++)
	{
		DataProvider.SetElementString(i, Player1.TSConversationManager.ConversationList[ConversationId].PlayerResponses[PlayerResponseIndices[i]].Response);
	}
	PlayerResponsesList.SetObject("dataProvider", DataProvider);

	NPCName.SetString("text", Player1.CurrentNPC.PawnName);
	NPCResponses.SetString("text", Player1.TSConversationManager.ConversationList[ConversationId].NPCResponses[NPCResponseIndex].Response);
}

/* Event:
 * SetQuestDescription(int questId)
 * Description:
 * This function is called by Actionscript to update the contents of the description flash object when the index is selected from the
 * quest log list.
 */
event SelectPlayerResponse(int responseId) //called by actionscript
{
	local int StartedConversationIndex;
	local int ConversationIndex;
	local int ConversationId;
	local int PlayerResponseId;
	local MyPawn Player1;

	Player1 = MyPawn(GetPC().Pawn);
	StartedConversationIndex = Player1.TSConversationManager.ConversationsStarted.Find('NPCId', Player1.CurrentNPC.PawnId); //The current index of conversation set between the player and NPC
	ConversationIndex = Player1.TSConversationManager.ConversationsStarted[StartedConversationIndex].ConversationIndex; //The current conversation index of the conversation set (the state of the conversation)
	ConversationId = Player1.CurrentNPC.Conversations[ConversationIndex]; //The actual ConversationID of the current conversation state (to be used to gather the data from the master conversation list)

	//This is the player response index for checking against the master list of player responses in the current conversation.
	PlayerResponseId = Player1.TSConversationManager.ConversationList[ConversationId].NPCResponses[NPCResponseIndex].PlayerResponseIndices[responseId];
	//Log which decision has been made, this is so that we can track player decisions (for conversation, current npc response, and the player response chosen (against master list))
	Player1.TSConversationManager.AddDecision(ConversationId, NPCResponseIndex, PlayerResponseId);
	//Set the next NPCResponse for the current conversation
	NPCResponseIndex = Player1.TSConversationManager.ConversationList[ConversationId].PlayerResponses[PlayerResponseId].NPCResponseIndex;
	//Check through decisions incase an event is triggered (i.e. give item)
	Player1.TSEventManager.PostDecisionCheck();

	//Close Conversation if NPCResponse is -1
	if (NPCResponseIndex == -1)
	{
		Player1.TSConversationManager.bInConversation = false;
	}
}

DefaultProperties
{
	bEnableGammaCorrection = False
	bIgnoreMouseInput = false
	bDisplayWithHudOff=true
	//bAllowInput=TRUE
	//bAllowFocus=TRUE
	//bCaptureInput=true
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_ConversationMenu'
}
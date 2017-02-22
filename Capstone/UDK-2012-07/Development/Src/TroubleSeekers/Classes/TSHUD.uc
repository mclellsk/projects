class TSHUD extends UTHUDBase;

//HUD Flash Object
var GFxHUD HudMovie;

//Cursor Movie Object
var TS_Cursor CursorMovie;
//Pause Menu Movie Object
var TS_PauseMenu PauseMenuMovie;
//Quest Menu Movie Object
var TS_QuestMenu QuestMenuMovie;
//Inventory Menu Movie Object
var TS_InventoryMenu InventoryMenuMovie;
//Stat Menu Movie Object
var TS_StatMenu StatMenuMovie;
//Conversation Display
var TS_ConversationMenu ConversationMenuMovie;
//Menu Buttons
var TS_MenuButtons MenuButtonsMovie;

//Mouse Flash Object
var GFxObject HudMovieSize;
//Mouse Input Controller
var MouseInterfacePlayerInput MouseInterfacePlayerInput;
//Mouse Position
var float MouseX, MouseY;
//Visible Cursor Toggle
var bool bShowCursor;
//Conversation started bool
var bool bConversationStarted;

//NPC Floating Display Properties
struct npcStatus
{
	var TS_Pawn TSPawn;
	var TS_NPCWorldDisplay PawnDisplay;
};

//Array of NPC Floating Displays
var array<npcStatus> NPCList;
//Array of Quests-in-Progress Displays
var array<TS_HUD_Quests> QuestDisplays;
//Array of Notifications
var array<TS_HUDNotification> HUDNotificationList;
//Array of FloatDmg
var array<TS_HUDFloatDmg> HUDFloatDmgList;

var int ScreenWidth;
var int ScreenHeight;

/* Function:
 * PostBeginPlay()
 * Description:
 * Initializes the scaleform movie menu displays, hud, quest progress frames and cursor.
 */
simulated function PostBeginPlay() {
	local int i;
	local TS_HUD_Quests quest;
	local vector position;

	super.PostBeginPlay();

	ScreenWidth = 1280;
	ScreenHeight = 720;
	bConversationStarted = false;

	if (PauseMenuMovie == None)
	{
		PauseMenuMovie = new class'TS_PauseMenu';
		PauseMenuMovie.SetTimingMode(TM_Real);
	}

	if (QuestMenuMovie == None)
	{
		QuestMenuMovie = new class'TS_QuestMenu';
		QuestMenuMovie.SetTimingMode(TM_Real);
	}

	if (InventoryMenuMovie == None)
	{
		InventoryMenuMovie = new class'TS_InventoryMenu';
		InventoryMenuMovie.SetTimingMode(TM_Real);
	}

	if (StatMenuMovie == None)
	{
		StatMenuMovie = new class'TS_StatMenu';
		StatMenuMovie.SetTimingMode(TM_Real);
	}

	if (HudMovie == none)
	{
		HudMovie = new class'GFxHUD';
		HudMovie.SetTimingMode(TM_Real);
		HudMovie.Initialize();
	}

	if (ConversationMenuMovie == none)
	{
		ConversationMenuMovie = new class'TS_ConversationMenu';
		ConversationMenuMovie.SetTimingMode(TM_Real);
	}

	if (MenuButtonsMovie == None)
	{
		MenuButtonsMovie = new class'TS_MenuButtons';
		MenuButtonsMovie.SetTimingMode(TM_Real);
	}

	if (CursorMovie == None)
	{
		CursorMovie = new class'TS_Cursor';
		CursorMovie.SetTimingMode(TM_Real);
		CursorMovie.Initialize();
		SetShowCursor(true);
	}

	//Quests
	for (i = 0; i < 3; i++)
	{
		quest = None;

		position.X = ScreenWidth - 250; //250 is the width of the frame
		position.Y = 150 * i;
		position.Z = 0;

		if (quest == None)
		{
			quest = new class'TS_HUD_Quests';
			quest.SetTimingMode(TM_Real);
			quest.Initialize(position);
			if (QuestDisplays[i] == None)
			{
				QuestDisplays.AddItem(quest);
			}
		}
	}
}

/* Function:
 * SetShowCursor(bool showCursor)
 * Description:
 * Function which controls the visibility of the mouse, as well as updating the position of the mouse.
 */
exec function SetShowCursor(bool showCursor)
{
    CursorMovie.ToggleCursor(showCursor, MouseX, MouseY);
	HudMovieSize = CursorMovie.GetVariableObject("Stage.originalRect");
	MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);
	MouseX = MouseInterfacePlayerInput.MousePosition.X;
	MouseY = MouseInterfacePlayerInput.MousePosition.Y;
}

/* Function:
 * TogglePauseMenu()
 * Description:
 * Function which toggles the pause menu. If open, the HUD is hidden, if closed, HUD is 
 * hidden only when all other HUD hiding menus are closed.
 */
function TogglePauseMenu()
{
	if (PauseMenuMovie != none && PauseMenuMovie.bMovieIsOpen)
	{
		PauseMenuMovie.Close(False);

		PlayerOwner.SetPause(False);

		if (!StatMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
		{
			SetVisible(True);
		}
	}
	else
	{
		PauseMenuMovie.Start();
		PauseMenuMovie.Advance(0.f);
		PauseMenuMovie.Initialize();

		PlayerOwner.SetPause(True);

		if (!StatMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
		{
			SetVisible(False);
		}

		// Do not prevent 'escape' to unpause if running in mobile previewer
		if( !WorldInfo.IsPlayInMobilePreview() )
		{
			PauseMenuMovie.AddFocusIgnoreKey('Escape');
		}

		SetShowCursor(True);
	}
}

/* Function:
 * ToggleQuestMenu()
 * Description:
 * Function which toggles the quest menu. If open, the HUD is hidden, if closed, HUD is 
 * hidden only when all other HUD hiding menus are closed.
 */
exec event ToggleQuestMenu()
{
	if (QuestMenuMovie != none && QuestMenuMovie.bMovieIsOpen)
	{
		QuestMenuMovie.Close(False);

		if (!StatMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
		{
			SetVisible(True);
		}
	}
	else
	{
		QuestMenuMovie.Start();
		QuestMenuMovie.Advance(0.f);
		QuestMenuMovie.Initialize();

		if (!StatMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
		{
			SetVisible(False);
		}

		SetShowCursor(True);
	}
}

/* Function:
 * ToggleInventoryMenu()
 * Description:
 * Function which toggles the inventory menu. If open, the HUD is hidden, if closed, HUD is 
 * hidden only when all other HUD hiding menus are closed.
 */
exec event ToggleInventoryMenu()
{
	if (InventoryMenuMovie != none && InventoryMenuMovie.bMovieIsOpen)
	{
		InventoryMenuMovie.Close(False);

		if (!StatMenuMovie.bMovieIsOpen && !QuestMenuMovie.bMovieIsOpen)
		{
			SetVisible(True);
		}
	}
	else
	{
		InventoryMenuMovie.Start();
		InventoryMenuMovie.Advance(0.f);
		InventoryMenuMovie.Initialize();

		if (!StatMenuMovie.bMovieIsOpen && !QuestMenuMovie.bMovieIsOpen)
			SetVisible(False);

		SetShowCursor(True);
	}
}

/* Function:
 * ToggleStatMenu()
 * Description:
 * Function which toggles the stat menu. If open, the HUD is hidden, if closed, HUD is 
 * hidden only when all other HUD hiding menus are closed.
 */
exec event ToggleStatMenu()
{
	if (StatMenuMovie != none && StatMenuMovie.bMovieIsOpen)
	{
		StatMenuMovie.Close(False);

		if (!QuestMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
			SetVisible(True);
	}
	else
	{
		StatMenuMovie.Start();
		StatMenuMovie.Advance(0.f);
		StatMenuMovie.Initialize();

		if (!QuestMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
			SetVisible(False);

		SetShowCursor(True);
	}
}

/* Function:
 * ToggleStatMenu()
 * Description:
 * Function which toggles the stat menu. If open, the HUD is hidden, if closed, HUD is 
 * hidden only when all other HUD hiding menus are closed.
 */
exec event ToggleConversationMenu()
{
	if (ConversationMenuMovie != none && ConversationMenuMovie.bMovieIsOpen)
	{
		ConversationMenuMovie.Close(False);

		if (!QuestMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
			SetVisible(True);
	}
	else
	{
		ConversationMenuMovie.Start();
		ConversationMenuMovie.Advance(0.f);
		ConversationMenuMovie.Initialize();

		if (!QuestMenuMovie.bMovieIsOpen && !InventoryMenuMovie.bMovieIsOpen)
			SetVisible(False);

		SetShowCursor(True);
	}
}

function CreateHUDNotify(string message)
{
	local TS_HUDNotification HUDnotification;
	local Vector pos;

	pos.X = 1280/2;
	pos.Y = 720/2;
	pos.Z = 0;

	HUDnotification = new class'TS_HUDNotification';
	HUDnotification.SetTimingMode(TM_Real);
	HUDnotification.Initialize(pos, message);

	HUDNotificationList.AddItem(HUDnotification);
}

function CreateHUDFloatDmg(Vector pos, string message)
{
	local TS_HUDFloatDmg HUDFloatDmg;

	HUDFloatDmg = new class'TS_HUDFloatDmg';
	HUDFloatDmg.SetTimingMode(TM_Real);
	HUDFloatDmg.Initialize(pos, message);

	HUDFloatDmgList.AddItem(HUDFloatDmg);
}

event Tick(float DeltaTime)
{
	local MyPawn Player1;
	local int i;

	Player1 = MyPawn(PlayerOwner.Pawn);

	//Notification Displays - Appears in the middle of the screen for 2 seconds
	for (i = 0; i < Player1.NotificationList.Length; i++)
	{
		if (!Player1.NotificationList[i].bCreated)
		{
			CreateHUDNotify(Player1.NotificationList[i].Message);
			Player1.NotificationList[i].bCreated = true;
		}
	}

	//Notification Display Removal - when the timer is over, remove the movieclip.
	for (i = 0; i < Player1.NotificationList.Length; i++)
	{
		if (Player1.NotificationList[i].bRemoveNotification)
		{
			Player1.NotificationList.Remove(i,1);
			HUDNotificationList[i].Close();
			HUDNotificationList.Remove(i,1);
			i--;
		}
	}

	super.Tick(DeltaTime);
}

/* Event:
 * PostRender()
 * Description:
 * This event updates the contents of the quest display frames, it also updates the values for each NPC floating display and calls each menus TickHUD() function.
 */
event PostRender() {

	local TS_Pawn TSPawn;
	local MyPawn Player1;
	local npcStatus NPC;
	local int i,j;
	local bool PawnExists;
	local string description;

	super.PostRender();

	if (PlayerOwner == None || PlayerOwner.Pawn == None)
	{
		return;
	}
	
	Player1 = MyPawn(PlayerOwner.Pawn);

	//Menu Buttons
	if (!MenuButtonsMovie.bMovieIsOpen)
	{
		MenuButtonsMovie.Start();
		MenuButtonsMovie.Advance(0.f);
		SetShowCursor(True);
	}

	//FloatDmg Displays - Appears in the middle of the screen for 2 seconds
	for (i = 0; i < Player1.FloatDmgList.Length; i++)
	{
		if (!Player1.FloatDmgList[i].bCreated)
		{
			CreateHUDFloatDmg(Canvas.Project(Player1.FloatDmgList[i].Position), Player1.FloatDmgList[i].Message);
			Player1.FloatDmgList[i].bCreated = true;
		}
	}

	//FloatDmg Display Removal - when the timer is over, remove the movieclip.
	for (i = 0; i < Player1.FloatDmgList.Length; i++)
	{
		if (Player1.FloatDmgList[i].bRemoveNotification)
		{
			Player1.FloatDmgList.Remove(i,1);
			HUDFloatDmgList[i].Close();
			HUDFloatDmgList.Remove(i,1);
			i--;
		}
	}

	if (Player1.TSEventManager.QuestManager.CurrentQuestList.Length > 0)
	{
		Player1.TSEventManager.QuestManager.Update();
	}

	//Conversation Control Flow
	//If a conversation has started between an NPC and the player, and no previous conversation has started, toggle the menu on, and flag a conversation as started.
	if (Player1.TSConversationManager.bInConversation && !bConversationStarted)
	{
		//PlayerOwner.Pawn.WorldInfo.Game.Broadcast(PlayerOwner.Pawn, "Init Conversation Menu");
		ToggleConversationMenu();
		bConversationStarted = true;
	}
	else if (Player1.TSConversationManager.bInConversation && bConversationStarted)
	{
		//PlayerOwner.Pawn.WorldInfo.Game.Broadcast(PlayerOwner.Pawn, "Update Conversation Menu");
		ConversationMenuMovie.TickHUD();
	}
	else if (!Player1.TSConversationManager.bInConversation && bConversationStarted)
	{
		//PlayerOwner.Pawn.WorldInfo.Game.Broadcast(PlayerOwner.Pawn, "Close Conversation Menu");
		ToggleConversationMenu();
		bConversationStarted = false;
	}

	//Show 3 Quests on screen MAX
	for (i = 0; i < 3; i++)
	{
		if (QuestDisplays[i].bMovieIsOpen)
		{
			QuestDisplays[i].Close(False);
		}

		if (i < Player1.TSEventManager.QuestManager.CurrentQuestList.Length)
		{
			if (!Player1.TSEventManager.QuestManager.CurrentQuestList[i].isComplete)
			{
				description = "";
				if (!QuestDisplays[i].bMovieIsOpen)
				{
					QuestDisplays[i].Start();
					QuestDisplays[i].Advance(0.f);
				}
				QuestDisplays[i].QuestTitle.SetString("text", Player1.TSEventManager.QuestManager.CurrentQuestList[i].questName);
				for (j = 0; j < Player1.TSEventManager.QuestManager.CurrentQuestList[i].subQuests.Length; j++)
				{
					description $= Player1.TSEventManager.QuestManager.CurrentQuestList[i].subQuests[j].QuestDescription $ "\n";
					description $= Player1.TSEventManager.QuestManager.CurrentQuestList[i].subQuests[j].QuestTracking $ Player1.TSEventManager.QuestManager.CurrentQuestList[i].subQuests[j].CurrentCount $ "/" $  Player1.TSEventManager.QuestManager.CurrentQuestList[i].subQuests[j].QuestCount $"\n";
				}
				QuestDisplays[i].QuestDescription.SetString("text", description);
			}
			else
			{
				Player1.TSEventManager.QuestManager.CurrentQuestList.Remove(i,1);
				--i;
			}
		}
	}

	ForEach DynamicActors(class'TS_Pawn', TSPawn)
	{
		PawnExists = false;

		if (TSPawn != PlayerOwner.Pawn || TSPawn.Controller != PlayerOwner)
		{
			//Check if NPC has already been added to the list of current NPCs
			for (i = 0; i < NPCList.Length; i++)
			{
				if (NPCList[i].TSPawn == TSPawn)
				{
					if (NPCList[i].TSPawn.Health <= 0)
					{
						NPCList[i].PawnDisplay.Close();
					}
					else if (NPCList[i].TSPawn.Health > 0)
					{
						NPCList[i].PawnDisplay.TickHUD(NPCList[i].TSPawn);
						NPCList[i].PawnDisplay.UpdatePosition(Canvas.Project(TSPawn.Location));
					}
					PawnExists = true;
					break;
				}
			}
			//If the NPC is not already in the list, add it
			if (!PawnExists)
			{
				NPC.TSPawn = TSPawn;
				NPC.PawnDisplay = new class 'TS_NPCWorldDisplay';
				NPC.PawnDisplay.SetTimingMode(TM_Real);
				NPC.PawnDisplay.Initialize(Canvas.Project(TSPawn.Location));
				NPCList.AddItem(NPC);
			}
		}
	}

	HudMovie.TickHUD();
	QuestMenuMovie.TickHUD();
	StatMenuMovie.TickHUD();
	InventoryMenuMovie.TickHUD();
	PauseMenuMovie.TickHUD();
}

DefaultProperties
{
}

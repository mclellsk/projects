class TS_HUD_Quests extends GFxMoviePlayer;

//This script is supposed to handle displaying quest progress hud info.

//Quest Frame Flash Object
var GFxObject QuestDisplay;
//Quest Title Flash Object
var GFxObject QuestTitle;
//Quest Description Flash Object
var GFxObject QuestDescription;
//Quest Frame Screen Position
var Vector Position;

/* Function:
 * Initialize(Vector ScreenPos)
 * Description:
 * Initialize the flash objects for the quest-in-progress display
 */
function Initialize(Vector ScreenPos)
{
	Start();
	Advance(0.f);

	Position = ScreenPos;

	QuestDisplay = AddQuestDisplay(Position);
	QuestTitle = QuestDisplay.GetObject("QuestTitle");
	QuestDescription = QuestDisplay.GetObject("QuestDescription");
}

/* Function:
 * GFxObject AddQuestDisplay(Vector ScreenPos)
 * Description:
 * This function adds a quest display frame to the screen at the screenpos specified.
 */
function GFxObject AddQuestDisplay(Vector ScreenPos)
{
	local GFxObject root;
	local GFxObject display;

	root = GetVariableObject("_root");
	display = root.AttachMovie("QuestDisplay","QuestDisplay");
	display.SetPosition(ScreenPos.X, ScreenPos.Y);
	
	return display;
}

DefaultProperties
{
	bDisplayWithHudOff = true;
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_QuestDisplay';
	//bAutoPlay = true;
	bCloseOnLevelChange = true;
	//Just put it in...
	bEnableGammaCorrection = false
}


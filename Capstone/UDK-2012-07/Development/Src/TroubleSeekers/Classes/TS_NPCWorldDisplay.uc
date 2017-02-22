class TS_NPCWorldDisplay extends GFxMoviePlayer;

//This script is supposed to handle displaying info above a pawn.

//Display MovieClip Flash Object
var GFxObject NPCDisplay;
//Health Bar Flash Object
var GFxObject barHealth;
//Health Text Flash Object
var GFxObject textHealth;
//NPC Name
var GFxObject npcName;
//Speech Bubble
var GFxObject speechDisplay;

//Previous Player Health
var float oldPlayerHealth;

/* Function:
 * int roundNum(float NumIn) 
 * Description:
 * This function rounds a float value to the nearest integer value.
 */
function int roundNum(float NumIn) 
{
	local int iNum;
	local float fNum;

	fNum = NumIn;
	iNum = int(fNum);
	fNum -= iNum;

	if (fNum >= 0.5f) {
		return (iNum + 1);
	}
	else {
		return iNum;
	}
}

/* Function:
 * int getpercent(int val, int max) 
 * Description:
 * This function returns a percentage from a value and a maximum.
 */
function int getpercent(int val, int max) 
{
	return round((float(val) / float(max)) * 100.0f);
}

/* Function:
 * Initialize(Vector ScreenPos)
 * Description:
 * This function initializes the flash objects from the scaleform .swf file.
 */
function Initialize(Vector ScreenPos)
{
	Start();
	Advance(0);

	oldPlayerHealth = 0;
	NPCDisplay = AddNPCDisplay(ScreenPos);
	barHealth = NPCDisplay.GetObject("Health_Bar");
	textHealth = NPCDisplay.GetObject("Health_Text");
	npcName = NPCDisplay.GetObject("NPC_Name");
	speechDisplay = NPCDisplay.GetObject("speech_mc");
}

/* Function:
 * GFxObject AddNPCDisplay(Vector ScreenPos)
 * Description:
 * This function creates a floating display at the vector location passed to the function.
 */
function GFxObject AddNPCDisplay(Vector ScreenPos)
{
	local GFxObject root;
	local GFxObject display;

	root = GetVariableObject("_root");
	display = root.AttachMovie("NPC_Display","NPCDisplay");
	display.SetPosition(ScreenPos.X, ScreenPos.Y);
	
	return display;
}

/* Function:
 * UpdatePosition(Vector ScreenPos)
 * Description:
 * This function updates the position of an npc floating display.
 */
function UpdatePosition(Vector ScreenPos)
{
	NPCDisplay.SetPosition(ScreenPos.X, ScreenPos.Y - 25);
}

/* Function:
 * TickHUD(UTPawn npcPawn)
 * Description:
 * This function updates the content of the health text and health bar for the NPC specified.
 */
function TickHUD(TS_Pawn npcPawn) 
{
	local TS_Pawn NPC;
	local float healthPercentage;

	healthPercentage = 0;
	NPC = npcPawn;

	//If the cached value for Health percentage isn't equal to the current...
	if (oldPlayerHealth != NPC.Health) 
	{
		oldPlayerHealth = NPC.Health;
		healthPercentage = getpercent(oldPlayerHealth, NPC.HealthMax);

		//Update xscale of bar, prevent under 0, over 100 scaling
		if (healthPercentage < 0) 
			healthPercentage = 0; 
		else if (healthPercentage > 100) 
			healthPercentage = 100;
		barHealth.SetFloat("_xscale", healthPercentage);
		textHealth.SetString("text", string (round(NPC.Health)));
		npcName.SetString("text", npcPawn.PawnName);
		if (NPC.bConverse)
		{
			speechDisplay.GotoAndStop("speech");
		}
		else
			speechDisplay.GotoAndStop("nospeech");
	}
}

DefaultProperties
{
	bDisplayWithHudOff = false;
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_NPCDisplay';
	//bAutoPlay = true;
	bCloseOnLevelChange = true;
	//Just put it in...
	bEnableGammaCorrection = false
}

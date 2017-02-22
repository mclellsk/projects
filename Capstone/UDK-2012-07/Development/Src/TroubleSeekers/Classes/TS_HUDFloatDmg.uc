class TS_HUDFloatDmg extends GFxMoviePlayer;

//This script is supposed to handle displaying info above a pawn.

//Notification
var GFxObject FloatDmgMC;
//Text
var GFxObject FloatDmgText;

/* Function:
 * Initialize(Vector ScreenPos)
 * Description:
 * This function initializes the flash objects from the scaleform .swf file.
 */
function Initialize(Vector ScreenPos, string Message)
{
	Start();
	Advance(0.f);

	ScreenPos.Y -= 25;
	ScreenPos.Z = 0;

	FloatDmgMC = AddFloatDmg(ScreenPos);
	FloatDmgText = FloatDmgMC.GetObject("floatdmg").GetObject("text");
	FloatDmgText.SetString("text", Message);
}

/* Function:
 * GFxObject AddNPCDisplay(Vector ScreenPos)
 * Description:
 * This function creates a floating display at the vector location passed to the function.
 */
function GFxObject AddFloatDmg(Vector ScreenPos)
{
	local GFxObject root;
	local GFxObject display;

	root = GetVariableObject("_root");

	display = root.AttachMovie("HitValue","HitValueMC");
	display.SetPosition(ScreenPos.X, ScreenPos.Y);
	
	return display;
}

DefaultProperties
{
	bDisplayWithHudOff = true;
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_HitValues';
	//bAutoPlay = true;
	bCloseOnLevelChange = true;
	//Just put it in...
	bEnableGammaCorrection = false
}

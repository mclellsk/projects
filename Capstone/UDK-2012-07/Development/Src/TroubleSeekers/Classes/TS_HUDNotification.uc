class TS_HUDNotification extends GFxMoviePlayer;

//This script is supposed to handle displaying info above a pawn.

//Notification
var GFxObject NotificationMC;
//Text
var GFxObject NotificationText;

/* Function:
 * Initialize(Vector ScreenPos)
 * Description:
 * This function initializes the flash objects from the scaleform .swf file.
 */
function Initialize(Vector ScreenPos, string Message)
{
	Start();
	Advance(0.f);

	NotificationMC = AddNotification(ScreenPos);
	NotificationText = NotificationMC.GetObject("notification").GetObject("text");
	NotificationText.SetString("text", Message);
	NotificationMC.GotoAndPlay("Notify");
}

/* Function:
 * GFxObject AddNPCDisplay(Vector ScreenPos)
 * Description:
 * This function creates a floating display at the vector location passed to the function.
 */
function GFxObject AddNotification(Vector ScreenPos)
{
	local GFxObject root;
	local GFxObject display;

	root = GetVariableObject("_root");

	display = root.AttachMovie("Notification","NotificationMC");
	display.SetPosition(ScreenPos.X, ScreenPos.Y);
	
	return display;
}

DefaultProperties
{
	bDisplayWithHudOff = true;
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_NotificationHUD';
	//bAutoPlay = true;
	bCloseOnLevelChange = true;
	//Just put it in...
	bEnableGammaCorrection = false
}

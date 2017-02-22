class TS_PauseMenu extends GFxMoviePlayer dependson (TS_Items);

//Root Flash Object
var GFxObject RootMC;
//Resume Button Flash Object
var GFxObject PauseButton;
//Quit Button Flash Object
var GFxObject QuitButton;

/* Function:
 * Initialize(optional LocalPlayer LocPlay)
 * Description:
 * Initialize the flash objects for the pause menu.
 */
function Initialize(optional LocalPlayer LocPlay)
{
	PauseButton = RootMC.GetObject("PauseBtn");
	QuitButton = RootMC.GetObject("QuitButton");
}

/* Function:
 * TickHUD()
 * Description:
 * Called to update the PauseMenu once per game tick.
 */
function TickHUD()
{
}

event PauseGame()
{
	ConsoleCommand("ShowMenu");
}

event QuitGame()
{
	ConsoleCommand("exit");
}


DefaultProperties
{
	bDisplayWithHudOff = true;
	bEnableGammaCorrection = False
	//bIgnoreMouseInput = true
	//bAllowInput=false
	//bAllowFocus=TRUE
	//bCaptureInput=true
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_PauseMenu'
}

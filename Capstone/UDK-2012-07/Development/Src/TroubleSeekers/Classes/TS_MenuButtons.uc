class TS_MenuButtons extends GFxMoviePlayer dependson (TS_Items);

/* Actionscript Flash Objects
 * Description:
 * These are flash objects associated with the flash .swf file
 * for the Stat Menu which displays the player character info.
 * This allows the player data to interface with the menu.
 */

event ToggleStats()
{
	ConsoleCommand("ToggleStatMenu");
}

event ToggleInventory()
{
	ConsoleCommand("ToggleInventoryMenu");
}

event ToggleQuestLog()
{
	ConsoleCommand("ToggleQuestMenu");
}

event TogglePauseMenu()
{
	ConsoleCommand("ShowMenu");
}

DefaultProperties
{
	bEnableGammaCorrection = False
	bIgnoreMouseInput = false
	bDisplayWithHudOff=true
	//bAllowInput=TRUE
	//bAllowFocus=TRUE
	//bCaptureInput=True
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_MenuButtons'
}
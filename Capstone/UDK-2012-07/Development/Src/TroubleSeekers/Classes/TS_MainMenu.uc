class TS_MainMenu extends UTHUDBase;

//HUD Flash Object
var TS_MainMenuHUD HudMovie;
//Cursor Movie Object
var TS_Cursor CursorMovie;
//Mouse Flash Object
var GFxObject HudMovieSize;
//Mouse Input Controller
var MouseInterfacePlayerInput MouseInterfacePlayerInput;
//Mouse Position
var float MouseX, MouseY;
//Visible Cursor Toggle
var bool bShowCursor;

var int ScreenWidth;
var int ScreenHeight;

/* Function:
 * PostBeginPlay()
 * Description:
 * Initializes the scaleform movie menu displays, hud, quest progress frames and cursor.
 */
simulated function PostBeginPlay() {
	super.PostBeginPlay();

	ScreenWidth = 1280;
	ScreenHeight = 720;

	if (HudMovie == none)
	{
		HudMovie = new class'TS_MainMenuHUD';
		HudMovie.SetTimingMode(TM_Real);
		HudMovie.Start();
		HudMovie.Advance(0.f);
	}

	if (CursorMovie == None)
	{
		CursorMovie = new class'TS_Cursor';
		CursorMovie.SetTimingMode(TM_Real);
		CursorMovie.Initialize();
		SetShowCursor(true);
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

/* Event:
 * PostRender()
 * Description:
 * This event updates the contents of the quest display frames, it also updates the values for each NPC floating display and calls each menus TickHUD() function.
 */
event PostRender() 
{
	super.PostRender();
}

DefaultProperties
{
}

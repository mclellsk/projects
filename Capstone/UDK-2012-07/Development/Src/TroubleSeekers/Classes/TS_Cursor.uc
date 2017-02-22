class TS_Cursor extends GFxMoviePlayer;

//Root Flash Object
var GFxObject RootMC;
//Mouse MovieClip Flash Objects
var GFxObject MouseContainer, MouseCursor;

//Actionscript arguments
var array<ASValue> args;

/* Function:
 * Initialize(optional LocalPlayer LocPlay)
 * Description:
 * Initialize the flash objects for the cursor.
 */
function Initialize()
{
	Start();
	Advance(0.f);
	RootMC = GetVariableObject("_root");
}

/* Event:
 * UpdateMousePosition(float X, float Y)
 * Description:
 * Update the mouse position, based on the input (x,y) from the flash file.
 */
event UpdateMousePosition(float X, float Y)
{
    local MouseInterfacePlayerInput MouseInterfacePlayerInput;
    MouseInterfacePlayerInput = MouseInterfacePlayerInput(GetPC().PlayerInput);
    if (MouseInterfacePlayerInput != None)
    {
        MouseInterfacePlayerInput.SetMousePosition(X, Y);
    }
}

/* Function:
 * ToggleCursor(bool showCursor, float mx, float my)
 * Description:
 * Toggles the visibility of the mouse cursor.
 */
function ToggleCursor(bool showCursor, float mx, float my)
{	
    if (showCursor)
    {
		Close(false);

		Start();

		if (MouseContainer == none)
		{
			MouseContainer = CreateMouseCursor();
			MouseCursor = MouseContainer.GetObject("Mouse_Cursor");
			MouseCursor.SetPosition(mx,my);
			MouseContainer.SetBool("topmostLevel", true);
		}
    }
}

/* Function:
 * GFxObject CreateMouseCursor()
 * Description:
 * Creates the mouse cursor based on the movieclip MouseContainer in the swf.
 */
function GFxObject CreateMouseCursor()
{
    return RootMC.AttachMovie("MouseContainer", "MouseCursor");
}

DefaultProperties
{
	bEnableGammaCorrection = False
	bIgnoreMouseInput = false
	bDisplayWithHudOff=true
	//bAllowInput=TRUE
	//bAllowFocus=TRUE
	//bCaptureInput=true
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_Cursor'
}
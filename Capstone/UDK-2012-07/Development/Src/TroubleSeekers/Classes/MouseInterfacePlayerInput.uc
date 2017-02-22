class MouseInterfacePlayerInput extends PlayerInput;

//Stored mouse position.
var IntPoint MousePosition; 
var TSHUD SFHudWrapper;
var float viewportWidth, viewportHeight;

/* Event:
 * PlayerInput(float DeltaTime)
 * Description:
 * Called when player input is given. Extended to clamp the mouse position to the
 * viewport.
 */
event PlayerInput(float DeltaTime)
{
    GetHudSize();
	
    if (myHUD != None) 
    {
		//Add the aMouseX to the mouse position and clamp it within the viewport width
		MousePosition.X = Clamp(MousePosition.X + aMouseX, 0, viewportWidth); 
		//Add the aMouseY to the mouse position and clamp it within the viewport height
		MousePosition.Y = Clamp(MousePosition.Y - aMouseY, 0, viewportHeight); 
    }
    Super.PlayerInput(DeltaTime);
}



/* Function:
 * GetHudSize()
 * Description:
 * This function gets the width and height of the SWF that holds the HUD.
 */
function GetHudSize()
{
    // First store a reference to our HUD Wrapper and get the resolution of the HUD
    SFHudWrapper = TSHUD(myHUD);
    viewportWidth = SFHudWrapper.HudMovieSize.GetFloat("width");
    viewportHeight = SFHudWrapper.HudMovieSize.GetFloat("height");
}

/* Function:
 * SetMousePosition(int X, int Y)
 * Description:
 * This function overrides the SetMousePosition function to clamp within the viewport.
 */
function SetMousePosition(int X, int Y)
{
    GetHudSize();
	
    if (MyHUD != None)
    {
		MousePosition.X = Clamp(X, 0, viewportWidth);
		MousePosition.Y = Clamp(Y, 0, viewportHeight);
    }
}

defaultproperties
{
}
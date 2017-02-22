class TS_MainMenuHUD extends GFxMoviePlayer;

event StartGame()
{
	ConsoleCommand("open TS-Dungeon");
}

event QuitGame()
{
	ConsoleCommand("exit");
}

DefaultProperties
{
	bDisplayWithHudOff=true
	//SWF Containing HUD
	MovieInfo=SwfMovie'TroubleSeekers_HUD.TS_MainMenu'
	bEnableGammaCorrection = false
}

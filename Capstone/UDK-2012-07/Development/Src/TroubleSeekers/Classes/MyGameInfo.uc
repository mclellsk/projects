class MyGameInfo extends UTDeathmatch;

//Player
var MyPlayerController currentPlayer;

/* Function:
 * RestartPlayer(Controller aPlayer)
 * Description:
 * Controls the behaviour when the player is reset (after death).
 */
function RestartPlayer(Controller aPlayer)
{
	super.RestartPlayer(aPlayer);
	`Log("Player restarted");
	currentPlayer = MyPlayerController(aPlayer);
	currentPlayer.resetMesh();
}

/* Function:
 * PostBeginPlay() 
 * Description:
 * Initializes the player controller class for this game type.
 */
simulated function PostBeginPlay() 
{
	local MyGameInfo Game;
	Super.PostBeginPlay();

	Game = MyGameInfo(WorldInfo.Game);

	if (Game != None)
	{
		Game.PlayerControllerClass=Class'TroubleSeekers.MyPlayerController';
	}
}

defaultproperties
{
	//All maps with this acronym 'TS-name' use this game type
	Acronym="TS"
	//Default pawn in this mode
	DefaultPawnClass=class'TroubleSeekers.MyPawn'
	//Default player controller for this mode
	PlayerControllerClass=Class'TroubleSeekers.MyPlayerController'
	//HUD used for this mode
	HUDType=class'TroubleSeekers.TSHUD'

	bUseClassicHUD=true
	bDelayedStart=false
	bRestartLevel=false

	Name="Default__MyGameInfo"
}
class TS_StatMenu extends GFxMoviePlayer dependson (TS_Items);

/* Actionscript Flash Objects
 * Description:
 * These are flash objects associated with the flash .swf file
 * for the Stat Menu which displays the player character info.
 * This allows the player data to interface with the menu.
 */

//Health Flash Object
var GFxObject HealthStat;
//Mana Flash Object
var GFxObject ManaStat;
//Attack Speed Flash Object
var GFxObject AtkspdStat;
//Move Speed Flash Object
var GFxObject MovespdStat;
//Attack Damage Flash Object
var GFxObject AtkdmgStat;
//Health Regen Flash Object
var GFxObject HealthRegenStat;
//Mana Regen Flash Object
var GFxObject ManaRegenStat;
//Critical Chance Flash Object
var GFxObject CriticalChanceStat;

/* Function:
 * Initialize(optional LocalPlayer LocPlay)
 * Description:
 * This function initializes each GFxObject, associating it with the 
 * correct flash movie clip object/instance.
 */
function Initialize(optional LocalPlayer LocPlay)
{
	HealthStat = GetVariableObject("_root.mc_disp_health.text_disp");
	ManaStat = GetVariableObject("_root.mc_disp_mana.text_disp");
	AtkspdStat = GetVariableObject("_root.mc_disp_atkspd.text_disp");
	MovespdStat = GetVariableObject("_root.mc_disp_movespd.text_disp");
	AtkdmgStat = GetVariableObject("_root.mc_disp_atkdmg.text_disp");
	HealthRegenStat = GetVariableObject("_root.mc_disp_healthregen.text_disp");
	ManaRegenStat = GetVariableObject("_root.mc_disp_manaregen.text_disp");
	CriticalChanceStat = GetVariableObject("_root.mc_disp_critchance.text_disp");
}

/* Function:
 * TickHUD()
 * Description:
 * This function updates the contents of the Stat Menu objects to reflect the 
 * player stats in real time. Runs once every game tick. Truncates floating points
 * to display up to 4 digits from the left.
 */
function TickHUD()
{
	local MyPawn _Player;
	_Player = MyPawn(GetPC().Pawn);

	HealthStat.SetString("text",string(_Player.HealthMax));
	AtkspdStat.SetString("text",(Left(string(RoundFloat(_Player.FireRateMultiplier)), 4)));
	AtkdmgStat.SetString("text",string(int(TS_Weapon(_Player.Weapon).InstantHitDamage[0])));
	MovespdStat.SetString("text",string(int(_Player.GroundSpeed)));
	ManaStat.SetString("text",string(_Player.ManaMax));
	ManaRegenStat.SetString("text",(Left(string(_Player.RegenManaPerSec),4)));
	HealthRegenStat.SetString("text",(Left(string(_Player.RegenHealthPerSec),4)));
	CriticalChanceStat.SetString("text",(Left(string(_Player.CriticalChance),4)));
}

/* Function:
 * float RoundFloat(float number)
 * Description:
 * This function rounds floats to 2 decimal places.
 */
function float RoundFloat(float number)
{
	return float((int(number * 100)) / 100);
}

event CloseStats()
{
	ConsoleCommand("ToggleStatMenu");
}

DefaultProperties
{
	bEnableGammaCorrection = False
	bIgnoreMouseInput = false
	bDisplayWithHudOff=true
	//bAllowInput=TRUE
	//bAllowFocus=TRUE
	//bCaptureInput=True
	MovieInfo = SwfMovie'TroubleSeekers_HUD.TS_StatMenu'
}

package
{
        import flash.display.Stage;
        import org.flixel.*;

        public class Registry
        {
            //public static var level:Level;
			public static var SWFWIDTH:int;
			public static var SWFHEIGHT:int;
			
			public static var player:Player;
			public static var groupManager:GroupManager;
			public static var eventChooser:EventChooser;
			public static var hud:HUD;
			//Controls line stoppage
			public static var isStopped:Boolean = true;
			//Time
			public static var timeElapsed:Number = 0;
			//Checklist (array<combination>)
			public static var checkList:Array = new Array();
			//Difficulty
			public static const EASY:int = 0;
			public static const NORMAL:int = 1;
			public static const HARD:int = 2;
			public static const INSANE:int = 3;
			public static var difficulty:int = 0;
			//Scores
			public static var mistakes:int = 0;
			public static var accepted:int = 0;
			
			public static var isSelecting:Boolean = false;
			public static var leftScreenWarning:Boolean = false; //fires when the line of people goes off the screen
            //public static var player:Player;
			public static var darkness:FlxSprite;
			
			public function Registry()
			{
			}
        }
}
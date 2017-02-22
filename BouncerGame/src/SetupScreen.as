package  
{
	import org.flixel.*;
	import flash.display.StageDisplayState;
	import flash.system.Capabilities;
	
	public class SetupScreen extends FlxState
	{
		
		public function SetupScreen() 
		{
			FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
			Registry.SWFHEIGHT = 200;
			Registry.SWFWIDTH = 340;
			FlxG.stage.stageHeight = Capabilities.screenResolutionY;
			FlxG.stage.stageWidth = Capabilities.screenResolutionX;
			FlxG.width = FlxG.stage.stageWidth / FlxCamera.defaultZoom;
			FlxG.height = FlxG.stage.stageHeight / FlxCamera.defaultZoom;
			trace (FlxG.stage.stageWidth);
			trace (FlxCamera.defaultZoom);
		}
		
		override public function update():void 
		{
			FlxG.switchState(new MenuState());
		}
		
	}

}
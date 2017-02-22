package
{
	import org.flixel.*; //Allows you to refer to flixel objects in your code
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;

	[SWF(width = "680", height = "400", backgroundColor = "#000000")] //Set the size and color of the original Flash file
	[Frame(factoryClass="Preloader")]
	public class Main extends FlxGame
	{
		public function Main():void
		{
			super(340, 200, SetupScreen, 2, 60, 60); //Create a new FlxGame object at 320x240 with 2x pixels, then load PlayState at 60fps
		}
	}
}

//IDEAS
//Player is an alien doing a research project
//Three types of blocks: Present, past, future
//Past blocks used for building
//Present blocks used for decoration
//Future blocks manipulate attributes




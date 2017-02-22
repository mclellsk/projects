package
{
	import flash.media.SoundMixer;
	import flash.display.StageScaleMode;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.net.SharedObject;
	
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequestMethod;
	import flash.events.Event;
	
	import org.flixel.*;
 
	public class MenuState extends FlxState
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//------------------------------------------DECLARATIONS---------------------------------------------
		[Embed(source = '../data/titlemusic.mp3')] private var titleMusic:Class; //music credit: http://binaryguy.newgrounds.com/
		[Embed(source = "../data/titlegraphic.png")] private var titleImg1:Class; //background image
		[Embed(source = "../data/titlegraphic2.png")] private var titleImg2:Class; //background image
		[Embed(source = "../data/titlegraphic3.png")] private var titleImg3:Class; //background image
		private var titleBackground1:FlxSprite;
		private var titleBackground2:FlxSprite;
		private var titleBackground3:FlxSprite;
		private var tempBackground:FlxSprite; //temporary backdrop object/fadein image
		private var tempBackground2:FlxSprite; //temporary backdrop object/fadein image
		
		private var helpText:FlxText;
		private var creditsText:FlxText;
		private var startButton:FlxButton;
		private var difficultyBtn:FlxButton;
		private var helpButton:FlxButton;
		private var lensFlares:LensFlares;
		
		private var helpUp:Boolean = false;
		private var titleTimer:Number = 0;
		
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		override public function create():void
		{	
			SoundMixer.stopAll();
			Reset();
			
			//Window setup
			FlxG.mouse.show(); //Make mouse visible
			FlxG.stage.scaleMode = StageScaleMode.EXACT_FIT; //Scale the stage to the window size, but preserve aspect ratio.
			FlxG.stage.align = ""; //Align the stage to the absolute center of the window.
			
			//Initialization - currently, order of initialization doesn't matter
			tempBackground = new FlxSprite(0, 0);
			tempBackground2 = new FlxSprite(FlxG.width, 0);
			titleBackground1 = new FlxSprite(0, 0);
			titleBackground2 = new FlxSprite(0, 0);
			titleBackground3 = new FlxSprite(0, 0);
			
			titleBackground1.loadGraphic(titleImg1, false, false, 340, 200, false);
			titleBackground2.loadGraphic(titleImg2, false, false, 340, 200, false);
			titleBackground3.loadGraphic(titleImg3, false, false, 340, 200, false);
			tempBackground.makeGraphic(FlxG.width, FlxG.height, 0xff000000, false); //Assign temporary background colour
			tempBackground2.makeGraphic(FlxG.width, FlxG.height, 0xff000000, false); //Assign temporary background colour
			tempBackground2.alpha = 0.75;
			
			helpText = new FlxText(Registry.SWFWIDTH, Registry.SWFHEIGHT / 2 - 6 * 16, 11 * 16, "GOATBOUNCER\n\nYou are one of the bouncers at the exclusive Club Goat! Your job is to turn down people who do not conform to the club's dress code.\n\n\nCONTROLS\n\n1. Hold the mouse button down on the right side of the screen to let people in.\n\n2. If a person's clothes match your description, click on them to (attempt to) turn them away!");
			//helpText.alignment = "center";
			creditsText = new FlxText(0, Registry.SWFHEIGHT - 1.5 * 16, Registry.SWFWIDTH, "Code/Sound: Nathan Mainville  Code/Visuals: Sean McLellan  Sound: Binaryguy (binaryguy.newgrounds.com) and SFXR");
			creditsText.alignment = "center";
			startButton = new FlxButton(Registry.SWFWIDTH / 2 - 5 * 8, (Registry.SWFHEIGHT) / 2 - 1*16, "Start", switchState);
			difficultyBtn = new FlxButton(Registry.SWFWIDTH / 2 - 5 * 8, (Registry.SWFHEIGHT + 40) / 2 - 1*16, "Difficulty: Easy", changeDifficulty);
			difficultyBtn.label.size = 6;
			helpButton = new FlxButton(Registry.SWFWIDTH / 2 - 5 * 8, (Registry.SWFHEIGHT + 80) / 2 - 1*16, "Help", helpToggle);
			
			lensFlares = new LensFlares();
			
			//trace(String(Registry.difficulty));
			add(titleBackground1);
			add(lensFlares);
			add(titleBackground2);
			add(titleBackground3);
			add(tempBackground2);
			add(helpText);
			add(startButton);
			add(difficultyBtn);
			add(helpButton);
			add(creditsText);
			add(tempBackground);
			FlxG.playMusic(titleMusic, 1.0);
		}
		
		override public function update():void
		{
			super.update();
			
			if (titleTimer < 20) titleTimer = titleTimer + FlxG.elapsed;
			if (titleTimer > 3 && tempBackground.alpha > 0) tempBackground.alpha = tempBackground.alpha - 0.25 * FlxG.elapsed;
			if (FlxG.keys.justPressed("SPACE") || FlxG.mouse.justPressed() && tempBackground.alpha > 0) tempBackground.alpha = 0;
			
			if (helpUp && startButton.x > (Registry.SWFWIDTH / 4 - 5*8))
			{
				startButton.velocity.x = ((Registry.SWFWIDTH / 4 - 5 * 8) - startButton.x - 1) * 3;
			}
			else if (helpUp && startButton.x < (Registry.SWFWIDTH / 4 - 5*8))
			{
				startButton.velocity.x = 0;
			}
			else if (!helpUp && startButton.x < (Registry.SWFWIDTH / 2 - 5*8))
			{
				startButton.velocity.x = ((Registry.SWFWIDTH / 2 - 5 * 8) - startButton.x + 1) * 3;
			}
			else if (!helpUp && startButton.x > (Registry.SWFWIDTH / 2 - 5*8))
			{
				startButton.velocity.x = 0;
			}
			
			helpButton.x = difficultyBtn.x = startButton.x;
			helpText.x = (startButton.x) * 3.1;
			tempBackground2.x = helpText.x;
		}
		
		public function switchState():void
		{
			FlxG.switchState(new PlayState);
		}
		
		public function changeDifficulty():void
		{
			//Cycles through difficulties.
			Registry.difficulty = (Registry.difficulty + 1)% 4;
			//trace(String(Registry.difficulty));
			switch (Registry.difficulty)
			{
				case 0:
					difficultyBtn.label.text = "Difficulty: Easy";
					//difficultyBtn.y = (FlxG.height + 40) / 2;
					difficultyBtn.label.alignment = "center";
					difficultyBtn.label.size = 6;
					Registry.difficulty = Registry.EASY;
					break;
				case 1:
					difficultyBtn.label.text = "Difficulty: Normal";
					//difficultyBtn.y = (FlxG.height + 40) / 2;
					difficultyBtn.label.alignment = "center";
					difficultyBtn.label.size = 6;
					Registry.difficulty = Registry.NORMAL;
					break;
				case 2:
					difficultyBtn.label.text = "Difficulty: Hard";
					//difficultyBtn.y = (FlxG.height + 40) / 2;
					difficultyBtn.label.alignment = "center";
					difficultyBtn.label.size = 6;
					Registry.difficulty = Registry.HARD;
					break;
				case 3:
					difficultyBtn.label.text = "Difficulty: Insane";
					//difficultyBtn.y = (FlxG.height + 40) / 2;
					difficultyBtn.label.alignment = "center";
					difficultyBtn.label.size = 6;
					Registry.difficulty = Registry.INSANE;
					break;
			}
		}
		
		public function Reset():void
		{
			Registry.groupManager = new GroupManager();
			Registry.hud = new HUD();
			//Controls line stoppage
			Registry.isStopped = true;
			//Time
			Registry.timeElapsed = 0;
			//Checklist
			Registry.checkList = new Array();
			//Difficulty
			Registry.difficulty = 0;
			//Scores
			Registry.mistakes = 0;
			Registry.isSelecting = false;
			Registry.leftScreenWarning = false; //fires when the line of people goes off the screen
		}
		
		public function helpToggle():void
		{
			helpUp = !helpUp
		}
	}
}
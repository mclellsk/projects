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
 
	public class PlayState extends FlxState
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//------------------------------------------DECLARATIONS---------------------------------------------
		[Embed(source = '../data/music.mp3')] private var bgMusic:Class; //music credit: http://binaryguy.newgrounds.com/
		[Embed(source = '../data/end1.mp3')] private var soundEnd1:Class;
		[Embed(source = "../data/Level.png")] private var bgSprite:Class; //background image
		[Embed(source = "../data/Level2.png")] private var bgSprite2:Class; //background image
		[Embed(source = "../data/Level3.png")] private var bgSprite3:Class; //foreground image
		private var tempBackground:FlxSprite; //temporary backdrop object
		private var tempBuilding:FlxSprite;
		private var tempForeground:FlxSprite;
		private var transition:FlxSprite = new FlxSprite(0,0);
		private var spawnInterval:Number = 1.5; //interval for sending people
		private var spawnCounter:Number = 0;
		private var spawnCounterMistake:Number = 0;
		private var loseMsg:FlxText;
		private var mainMenuBtn:FlxButton;
		private var isGameOver:Boolean = false;
		private var darkness:FlxSprite;
		private var pauseBtn:String = "ESCAPE";
		private var isPaused:Boolean = false;
		
		//private var player:Player; //debug player
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		override public function create():void
		{
			SoundMixer.stopAll();
			setTime(90);
			rollList();
			
			//Window setup
			FlxG.mouse.show(); //Make mouse visible
			FlxG.stage.scaleMode = StageScaleMode.SHOW_ALL; //Scale the stage to the window size, but preserve aspect ratio.
			FlxG.stage.align = ""; //Align the stage to the absolute center of the window.
			
			darkness = new FlxSprite(0, 0);
			darkness.makeGraphic(Registry.SWFWIDTH, Registry.SWFHEIGHT, 0xff000000);
			darkness.scrollFactor.x = darkness.scrollFactor.y = 0;
			darkness.blend = "multiply";
			darkness.alpha = 0.7;
			Registry.darkness = darkness;

			//Initialization - currently, order of initialization doesn't matter
			Registry.player = new Player(19 * 16, 11 * 16);
			Registry.groupManager = new GroupManager();
			Registry.eventChooser = new EventChooser();
			Registry.hud = new HUD();
			tempBackground = new FlxSprite(0, 0);
			tempBuilding = new FlxSprite(0, 0);
			tempForeground = new FlxSprite(0, 0);
			
			//tempBackground.makeGraphic(FlxG.width, FlxG.height, 0xff666666, false); //Assign temporary background colour
			tempBackground.loadGraphic(bgSprite, false, false, 340, 200);
			tempBuilding.loadGraphic(bgSprite2, false, false, 340, 200);
			tempForeground.loadGraphic(bgSprite3, false, false, 340, 200);
			
			add(tempBackground);
			add(Registry.eventChooser);
			add(tempBuilding);
			add(Registry.groupManager);
			add(tempForeground);
			add(Registry.player);
			var light:Light = new Light(295, 70 , darkness, 1, 0x1af7ff, 2, 1.5);
			var light2:Light = new Light(310, 100, darkness, 1, 0xff29b6, 5, 4);
			var light3:Light = new Light(140, 170, darkness, 1, 0x1af7ff, 11, 3.5);
			var light4:Light = new Light(295, 170, darkness, 1, 0xff29b6, 4, 3.5);
			add(light);
			add(light2);
			add(light3);
			add(light4);
			add(darkness);
			add(Registry.hud);
			
			Registry.mistakes = 0;
			Registry.accepted = 0;
			//FlxG.stream("../data/music.mp3", 1.0, true);
			FlxG.playMusic(bgMusic, 1);
		}
		
		override public function update():void
		{
			//if(FlxG.paused) SoundMixer.stopAll();
			
			checkGameOver();
			
			if (FlxG.keys.justPressed(pauseBtn))
			{
				transition.makeGraphic(FlxG.width, FlxG.height, 0xff000000);
				add(transition);
				switchState();
			}
			
			if (Registry.timeElapsed != 0)
			{
				updateTime();
				
				if (Registry.leftScreenWarning && Registry.isStopped == false) Registry.leftScreenWarning = false; //Turn warning off if things are moving
				
				spawnCounter = spawnCounter + FlxG.elapsed; //sends in a new person every second
				spawnCounterMistake = spawnCounterMistake + FlxG.elapsed;
				if (spawnCounter > spawnInterval && !Registry.leftScreenWarning)
				{
					//CHANGE THE SPAWN FLAG TO FALSE TO REMOVE FORCING OUTFITS
					spawnPerson(Registry.difficulty); //NOTE: there is a difficult bug that may happen where people stop spawning if they spawn completely off the edge of the screen
																		//currently, it seems like a temporary fix is to spawn people with a small part of them on screen
					spawnCounter = 0;
				}
				
				//if (FlxG.keys.justPressed("B")) FlxG.visualDebug = !FlxG.visualDebug; //bounding box debug
				//if (FlxG.keys.justReleased("R")) rollList(); //reroll list
				//if (FlxG.keys.justReleased("S")) FlxG.shake(0.01, 0.1, null, true, 1); //shake debug
			}
			super.update();
			
			FlxG.collide(Registry.groupManager, Registry.groupManager);
		}
		
		public function spawnPerson(difficulty:int):void
		{
			switch (difficulty)
			{
				case Registry.EASY:
					if (spawnCounterMistake > 8.0) //force someone to spawn on the list
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, true);
						spawnCounterMistake = 0;
					}
					else
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, false);
					}
					break;
				case Registry.NORMAL:
					if (spawnCounterMistake > 6.0) //force someone to spawn on the list
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, true);
						spawnCounterMistake = 0;
					}
					else
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, false);
					}
					break;
				case Registry.HARD:
					if (spawnCounterMistake > 4.0) //force someone to spawn on the list
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, true);
						spawnCounterMistake = 0;
					}
					else
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, false);
					}
					break;
				case Registry.INSANE:
					if (spawnCounterMistake > 2.0) //force someone to spawn on the list
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, true);
						spawnCounterMistake = 0;
					}
					else
					{
						Registry.groupManager.spawnPerson( -7, 11 * 16 - 4, false);
					}
					break;
			}
		}
		
		public function updateTime():void
		{
			if (Registry.timeElapsed <= 0)
			{
				Registry.timeElapsed = 0;
			}
			else
				Registry.timeElapsed -= FlxG.elapsed;
		}
		
		public function setTime(seconds:Number):void
		{
			Registry.timeElapsed = seconds;
		}
		
		public function addTime(seconds:Number):void
		{
			Registry.timeElapsed += seconds;
		}
		
		public function genClothing(type:int):Clothing
		{
			var item:int;
			var design:int;
			var ClothingItem:String;
			var ClothingDesign:String;
			var Cloth:Clothing;
			
			//item = Math.random() * 1.99;
			design = Math.random() * 4.99;
			
			switch (type)
			{
				case 0:
					ClothingItem = ClothingTypes.PANTS;
					break;
				case 1:
					ClothingItem = ClothingTypes.SHIRT;
					break;
			}
			
			switch (design)
			{
				case 0:
					ClothingDesign = DesignTypes.BLUE;
					break;
				case 1:
					ClothingDesign = DesignTypes.MAGENTA;
					break;
				case 2:
					ClothingDesign = DesignTypes.GREEN;
					break;
				case 3:
					ClothingDesign = DesignTypes.RED;
					break;
				case 4:
					ClothingDesign = DesignTypes.GOLD;
					break;
			}
			
			return Cloth = new Clothing(ClothingItem, ClothingDesign);
		}
		
		public function genCheckListItem():void
		{
			var bExists:Boolean = false;
			var bValid:Boolean = false;
			var clothingCombo:Combination = new Combination();
			var clothingPiece:Clothing;
			var pieces:int;
			
			//Difficulty check
			switch (Registry.difficulty)
			{
				case 0: //easy
					pieces = 0;
					break;
				case 1: //normal
					pieces = Math.random() * 1.99;
					break;
				case 2: //hard
					pieces = 1;
					break;
				case 3: //insane
					pieces = 1;
					break;
			}
			
			switch (pieces)
			{
				//1 piece
				case 0:
					//Continues to generate clothing until valid
					while (!bValid)
					{
						clothingPiece = genClothing(Math.random() * 1.99);
						clothingCombo.comboList.push(clothingPiece);
						if (!checkListForCombo(clothingCombo))
						{
							Registry.checkList.push(clothingCombo);
							bValid = true;
						}
					}
					break;
				//2 piece
				case 1:
					var clothingAvailable:Array = new Array();
					var item:int;
					while (!bValid)
					{
						//clear temp combo list
						clothingCombo.comboList.splice(0);
						//clear
						clothingAvailable.splice(0);
						
						//available clothing
						clothingAvailable.push(0);
						clothingAvailable.push(1);
						
						//trace(clothingAvailable.length);
						
						item = Math.random() * clothingAvailable.length;
						for (var i:int = 0; i < 2; i++)
						{
							clothingPiece = genClothing(clothingAvailable[item]);
							//trace(Clothing(clothingPiece).ClothingItem + "," + Clothing(clothingPiece).ClothingDesign);
							clothingCombo.comboList.push(clothingPiece);
							clothingAvailable.splice(item, 1);
							item = Math.random() * clothingAvailable.length;
						}
						
						//trace(!checkListForCombo(clothingCombo));
						if (!checkListForCombo(clothingCombo))
						{
							//trace("push combo to list");
							Registry.checkList.push(clothingCombo);
							bValid = true;
						}
					}
					break;
			}
		}
		
		//Checks the checklist for an entry matching the combination
		public function checkListForCombo(combo:Combination):Boolean
		{
			var match:Boolean = true;
			for (var l:int = 0; l < Registry.checkList.length; l++)
			{
				if (Registry.checkList[l] == combo)
				{
					//trace("match");
					return true;
				}
			}
			for (var i:int = 0; i < Registry.checkList.length; i++)
			{
				match = true;
				for (var j:int = 0; j < combo.comboList.length; j++)
				{
					for (var k:int = 0; k < (Combination(Registry.checkList[i]).comboList.length); k++)
					{
						if (Clothing(combo.comboList[j]).ClothingItem == Clothing(Combination(Registry.checkList[i]).comboList[k]).ClothingItem && Clothing(combo.comboList[j]).ClothingDesign == Clothing(Combination(Registry.checkList[i]).comboList[k]).ClothingDesign)
						{
							if ((combo.comboList.length == 1 || Combination(Registry.checkList[i]).comboList.length == 1))
							{
								//trace("match");
								return true;
							}
							break;
						}
						else if (k == Combination(Registry.checkList[i]).comboList.length - 1)
						{
							match = false;
							break;
						}
					}
					if (!match)
					{
						break;
					}
				}
				if (match)
				{
					//trace("match");
					return true;
				}
			}
			//trace("no match");
			return false;
		}
		
		//OLD
		//Checks the combo for a clothingtype that already exists (no pants, pants matches, etc)
		public function checkComboForClothing(combo:Combination, item:Clothing):Boolean 
		{
			for (var i:int = 0; i < combo.comboList.length; i++)
			{
				if (Clothing(combo.comboList[i]).ClothingItem == item.ClothingItem)
				{
					return true;
				}
			}
			return false;
		}
		
		public function generateCheckList(listSize:int):void
		{
			//clear objectives
			clearCheckList();
			//trace("size " + listSize);
			for (var i:int = 0; i < listSize; i++)
			{
				//trace("generate clothing combo");
				//trace(i);
				genCheckListItem();
			}
		}
		
		public function rollList():void
		{
			var size:int;
			
			//Difficulty check
			switch (Registry.difficulty)
			{
				case 0: //ez
					size = 1;
					break;
				case 1: //normal
					size = Math.random() * 2.99;
					if (size < 1)
						size = 1;
					break;
				case 2: //hard
					size = Math.random() * 3.99;
					if (size < 1)
						size = 2;
					break;
				case 3: //insane
					size = Math.random() * 4.99;
					if (size < 1)
						size = 3;
					break;
			}
			generateCheckList(size);
		}
		
		public function clearCheckList():void
		{
			Registry.checkList.splice(0);
		}
		
		public function checkGameOver():void
		{	
			if (Registry.timeElapsed == 0 && !isGameOver)
			{	
				Registry.hud.kill();
				//loseMsg = new FlxText((FlxG.width - 160) / 2, FlxG.height / 2 - 32, 160, "Game Over\n Your accuracy is "+ Math.floor(Registry.accepted/(Registry.accepted + Registry.mistakes)*100) +"%!");
				loseMsg = new FlxText((Registry.SWFWIDTH - 160) / 2, Registry.SWFHEIGHT / 2 - 32, 160, "Game Over\n Your score is " + String(500 + 10 * Registry.accepted - 10 * Registry.mistakes));
				if (500 + 10 * Registry.accepted - 10 * Registry.mistakes >= 1000) loseMsg.text = loseMsg.text + "! Woo hoo!";
				else if (500 + 10 * Registry.accepted - 10 * Registry.mistakes <= 0) loseMsg.text = loseMsg.text + "... Ouch.";
				else if (Registry.accepted == 0 && Registry.mistakes == 0) loseMsg.text = loseMsg.text + ". Wait, what?";
				loseMsg.alignment = "center";
				mainMenuBtn = new FlxButton((Registry.SWFWIDTH - 75) / 2, (Registry.SWFHEIGHT + 40) / 2 - 16, "Return", switchState);
				add(loseMsg);
				add(mainMenuBtn);
				isGameOver = true;
				FlxG.play(soundEnd1);
			}
		}
		
		public function switchState():void
		{
			FlxG.switchState(new MenuState);
		}
		
		public function resumeGame():void
		{
			isPaused = false;
		}
		
		override public function draw():void
		{
			darkness.fill(0xff000000);
			super.draw();
		}
	}
}
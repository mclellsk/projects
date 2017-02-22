package
{
	import org.flixel.*;
 
	public class HUD extends FlxGroup
	{	
		//------------------------------------------DECLARATIONS---------------------------------------------
		private const DROP_DOWN_BOX_UP:int = -155;
		private const CHECKLIST_OFFSET:int = 28;
		
		//public var scoreText:FlxText = new FlxText(5, 15, 64, "0");
		private var dropDownBox:FlxSprite = new FlxSprite(1 * 16, 0);
		public var timerText:FlxText = new FlxText(Registry.SWFWIDTH - 60, 0, 60, "0");
		public var checkListText:FlxText = new FlxText(dropDownBox.x + 14, dropDownBox.y + CHECKLIST_OFFSET, 120, "0");
		private var mistakesText:FlxText = new FlxText(Registry.SWFWIDTH / 2, 0, 5 * 16, "Mistakes: 0");
		private var currentMistakes:int = 0;
		private var objective:String = new String("");
		public var checkList:Array = new Array();
		private var droppedDown:Boolean = true;
		
		[Embed(source = "../data/phone.png")] private var phoneGfx:Class;
		[Embed(source="../data/fonts/upheavtt.ttf", fontFamily="PixText", embedAsCFF = "false")] private var FontPixTex:Class;
		
		//public var score:int = 0;
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function HUD():void //X and Y define starting position of the player
		{
			super();
			//Score
			//scoreText.scrollFactor.x = scoreText.scrollFactor.y = 0;
			timerText.scrollFactor.x = timerText.scrollFactor.y = 0;
			//timerText.setFormat("PixText");
			checkListText.scrollFactor.x = checkListText.scrollFactor.y = 0;
			//checkListText.setFormat("PixText", 12);
			//checkListText.antialiasing = false;
			dropDownBox.loadGraphic(phoneGfx, false, false, 144, 180);
			dropDownBox.maxVelocity.y = 250;
			dropDownBox.alpha = 1;
			
			//add(scoreText);
			add(dropDownBox);
			add(timerText);
			add(checkListText);
			add(mistakesText);
		}
		
		override public function update():void //update function
		{
			if (FlxG.mouse.x >= dropDownBox.x && FlxG.mouse.x < dropDownBox.x + dropDownBox.width && FlxG.mouse.y >= dropDownBox.y && FlxG.mouse.y < dropDownBox.y + dropDownBox.height && FlxG.mouse.justPressed()) droppedDown = !droppedDown;
			
			if (droppedDown && dropDownBox.y < 0) dropDownBox.velocity.y = 250;
			else if (!droppedDown && dropDownBox.y > DROP_DOWN_BOX_UP) dropDownBox.velocity.y = -250;
			else dropDownBox.velocity.y = 0;
			
			//scoreText.text = String(score);
			displayCheckList();
			updateTime();
			checkListText.y = dropDownBox.y + CHECKLIST_OFFSET;
			
			if (Registry.mistakes != currentMistakes)
			{
				currentMistakes = Registry.mistakes;
				mistakesText.text = "Mistakes: " + currentMistakes;
				mistakesText.scale.x = mistakesText.scale.y = 1.5;
			}
			
			
			super.update();
			
			if (mistakesText.scale.x > 1 || mistakesText.scale.y > 1) mistakesText.scale.x = mistakesText.scale.y = mistakesText.scale.x - 10 * FlxG.elapsed;
			else if (mistakesText.scale.x < 1 || mistakesText.scale.y < 1) mistakesText.scale.x = mistakesText.scale.y = 1;
			
		}
		
		public function updateTime():void
		{
			var timeSecs:int;
			var timeMin:int;
			var timeMilSecs:int;
			
			timeMin = Registry.timeElapsed / 60;
			timeSecs = Registry.timeElapsed - (timeMin * 60);
			timeMilSecs = Registry.timeElapsed * 100 - int(Registry.timeElapsed) * 100;
			
			timerText.text = String(timeMin) + ":" + String(timeSecs) + ":" + String(timeMilSecs);
		}
		
		public function displayCheckList():void
		{
			objective = "Reject patrons who are wearing the following. \n\n";
			
			for (var i:int = 0; i < Registry.checkList.length; i++)
			{
				objective += String(i + 1) + ". ";
				for (var j:int = 0; j < Combination(Registry.checkList[i]).comboList.length; j++)
				{
					objective += String(Clothing(Combination(Registry.checkList[i]).comboList[j]).ClothingDesign) + " " + String(Clothing(Combination(Registry.checkList[i]).comboList[j]).ClothingItem);
					if (j != Combination(Registry.checkList[i]).comboList.length - 1)
					{
						objective += " and ";
					}
				}
				//if (i != Registry.checkList.length - 1)
					objective += "\n";
			}
			checkListText.text = objective;
		}
	}
}
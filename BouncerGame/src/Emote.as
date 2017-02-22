package
{
	import org.flixel.*;
 
	public class Emote extends FlxSprite
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//this class' purpose is to provide a small effect for people to display (such as a "!" when startled or a "?" when confused)
		//------------------------------------------DECLARATIONS---------------------------------------------
		[Embed(source = "../data/Emotes.png")] public var emoteSprite:Class;
		private var actionCounter:Number = 0;
		public var emotionValue:int = 0;

		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function Emote(X: int, Y: int):void //X and Y define starting position of the player
		{
			super(X, Y); //x and y position of the person
			
			//makeGraphic(16, 16, 0xff00FF00, true);
			loadGraphic(emoteSprite, true, true, 16, 16, true);
			
			//Animations
			addAnimation("!", [0]);
			addAnimation("?", [1]);
			addAnimation("...", [2, 3, 4], 3, false);
			addAnimation("hemad", [5, 6, 7], 6, true);
			addAnimation("happy", [8]);
			addAnimation("shifty", [9, 10], 3, true);
			addAnimation("meh", [11]);
			play("!");
			
			solid = false;
			kill();
		}
		
		override public function update():void //update function
		{
			//------------------------------------------ANIMATIONS-----------------------------------------------
			//-------------------------------------------MOVEMENT------------------------------------------------
			
			actionCounter = actionCounter + FlxG.elapsed;
			if (actionCounter > 1) kill();
			
			if (scale.x > 1 || scale.y > 1) scale.x = scale.y = scale.x - 10 * FlxG.elapsed
			if (scale.x < 1 || scale.y < 1) scale.x = scale.y = 1;
			
			super.update();
		}
		
		public function playEmotion():void
		{
			switch(emotionValue)
			{
				case 1: play("!"); break;
				case 2: play("?"); break;
				case 3: play("..."); break;
				case 4: play("hemad"); break;
				case 5: play("happy"); break;
				case 6: play("shifty"); break;
				case 7: play("meh"); break;
				default: break;
			}
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			actionCounter = 0;
			scale.x = scale.y = 1.5;
			//emotionValue = Math.random() * 4;
			playEmotion();
		}
	}
}
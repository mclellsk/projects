package
{
	import org.flixel.*;
 
	public class Car extends FlxSprite
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//------------------------------------------DECLARATIONS---------------------------------------------
		[Embed(source = "../data/Car.png")] public var carSprite:Class;
		
		private const SPEED:int = 600;
		private var actionCounter:Number = 0;
		private var driveDirection:int = 0; //0 = left, 1 = right
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function Car():void
		{
			super(-200, -200); //x and y position of the person
			
			//makeGraphic(16, 16, 0xff00FF00, true);
			loadGraphic(carSprite, true, false, 145, 66);
			
			maxVelocity.x = 1000;
			//Animations
			//addAnimation("!", [0]);
			//play("!");
			
			kill();
		}
	
		override public function update():void //update function
		{
			//------------------------------------------ANIMATIONS-----------------------------------------------
			//-------------------------------------------MOVEMENT------------------------------------------------
			
			//actionCounter = actionCounter + FlxG.elapsed;
			//if (actionCounter > 1) kill();
			
			if (driveDirection == 1) velocity.x = SPEED;
			else if (driveDirection == 0) velocity.x = -SPEED;
			
			
			if (x > FlxG.width && driveDirection == 1) kill();
			else if (x < 0 - width && driveDirection == 0) kill();
			
			super.update();
		}
		
		public function resetCar(d:int):void
		{
			if (!alive)
			{
				driveDirection = 0;
				//if (driveDirection == 0)
				reset(FlxG.width, -12);
				//else if (driveDirection == 1) reset(0 - width, 46);
				//else trace("car direction must be 0 or 1 sillyface");
			}
		}
		
		override public function reset(X:Number, Y:Number):void
		{
			super.reset(X, Y);
			actionCounter = 0;
		}
	}
}
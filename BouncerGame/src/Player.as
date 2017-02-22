package  
{
	import org.flixel.*;
	
	public class Player extends FlxSprite
	{
		[Embed(source = "../data/Player_Sheet.png")] public var plSprite:Class;
		private var stoppedBtn:String = "SPACE";
		private var currentPoint:FlxPoint = new FlxPoint(0,0);
		private var nextPoint:FlxPoint;
		private var startPointX:int;
		private var startPointY:int;
		
		public function Player(X:int, Y:int):void
		{
			//start position
			startPointX = X;
			startPointY = Y;
			
			this.nextPoint = new FlxPoint(startPointX, startPointY); 
			
			super(X, Y);
			//makeGraphic(16, 16, 0xFFFFFFFF, true);
			loadGraphic(plSprite, true, true, 48, 48, true);
			
			offset.x = width/2;
			offset.y = height;
			width = 8;
			height = 16;
			offset.x = offset.x - width/2 + 8;
			offset.y = offset.y - height;
			
			addAnimation("idle", [0, 3, 0, 4], 2, true);
			addAnimation("pointback", [1, 0], 1, false);
			addAnimation("pointforward", [2, 0], 1, false);
			addAnimation("punch", [6, 5], 1, false);
			play("idle");
			
			Registry.isStopped = true;
			//trace("stop");
			//this.nextPoint.x = this.x - 16;
			//this.nextPoint.y = this.y - 16;
			this.nextPoint.x = startPointX - 16;
			this.nextPoint.y = startPointY - 16;
		}
		
		public function movePlayer(point:FlxPoint, speed:Number):void
		{
			if (Registry.timeElapsed > 0)
				{
				currentPoint = new FlxPoint(this.x, this.y);
				if (point.x != currentPoint.x)
				{
					velocity.x = (point.x - currentPoint.x) * speed * FlxG.elapsed * 60;
				}
				if (point.y != currentPoint.y)
				{
					velocity.y = (point.y - currentPoint.y) * speed * FlxG.elapsed * 60;
				}
			}
			else velocity.x = velocity.y = 0;
		}
		
		override public function update():void 
		{
			this.acceleration.x = 0;
			this.acceleration.y = 0;
			
			if (Registry.timeElapsed != 0)
			{
				//if (FlxG.keys.pressed(stoppedBtn) || (FlxG.mouse.pressed() && FlxG.mouse.x > (FlxG.width/6 * 4.85))) //either listen for a keypress or a mouseclick on the right side of the screen
				//{
					if (Registry.isStopped && ((FlxG.keys.pressed(stoppedBtn)) || (FlxG.mouse.pressed() && FlxG.mouse.x > (FlxG.width/6 * 4.85))))
					{
						play("idle");
						Registry.isStopped = false;
						//trace("wait");
						//this.nextPoint.x = this.x + 16;
						//this.nextPoint.y = this.y + 16;
						this.nextPoint.x = startPointX;
						this.nextPoint.y = startPointY;
						//Play wait animation
					}
					if (!Registry.isStopped && (FlxG.keys.justReleased(stoppedBtn) || FlxG.mouse.justReleased()))
					{
						play("idle");
						Registry.isStopped = true;
						//trace("stop");
						//this.nextPoint.x = this.x - 16;
						//this.nextPoint.y = this.y - 16;
						this.nextPoint.x = startPointX - 16;
						this.nextPoint.y = startPointY - 16;
						//Play stop animation
					}
				//}
				movePlayer(new FlxPoint(this.nextPoint.x, this.nextPoint.y),5);
				super.update();
			}	
		}
	}
}
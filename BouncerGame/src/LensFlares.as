package
{
	import org.flixel.*;
 
	public class LensFlares extends FlxGroup
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//this class' purpose is to make bitchin' lens flares
		//------------------------------------------DECLARATIONS---------------------------------------------
		private var spawnCountdown:Number = 0;
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function LensFlares()
		{
			super();
			
			for (var i:int = 0; i < 6; i++)
			{
				add(new FlxSprite( -100, -100));
				members[i].makeGraphic(32, FlxG.height, 0xffffffff);
				members[i].angle = 15;
				members[i].kill();
				
			}
			spawnCountdown = Math.random() * 3.5 + 0.5;
		}
		
		override public function update():void //update function
		{
			spawnCountdown = spawnCountdown - FlxG.elapsed;
			if (getFirstAvailable() && spawnCountdown < 0)
			{
				FlxSprite(getFirstAvailable()).scale.x = Math.random() * 1.3 + 0.20;
				FlxSprite(getFirstAvailable()).reset( -32, 0);
				spawnCountdown = Math.random() * 1.9 + 0.1;
			}
			
			for (var i:int = 0; i < 6; i++)
			{
				if (FlxSprite(members[i]).x < FlxG.width / 4 * 1) FlxSprite(members[i]).acceleration.x = 50;
				else if (FlxSprite(members[i]).x < FlxG.width / 4 * 2) FlxSprite(members[i]).acceleration.x = -25;
				else if (FlxSprite(members[i]).x < FlxG.width / 4 * 3) FlxSprite(members[i]).acceleration.x = 25;
				else if (FlxSprite(members[i]).x < FlxG.width / 4 * 4) FlxSprite(members[i]).acceleration.x = -50;
				
				if (members[i].alive && members[i].x > FlxG.width) members[i].kill();
				
				if (members[i].alive && members[i].velocity < 25) FlxSprite(members[i]).velocity.x = 25;
			}
			
			
			super.update();
		}
	}
}


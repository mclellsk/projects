package
{
	import org.flixel.*;

	public class GroupManager extends FlxGroup
	{
		protected const bloom:Number = 1.5;
		protected var bloomFx:FlxSprite;
		//------------------------------------------DECLARATIONS---------------------------------------------
		private const MAX_PEOPLE:int = 100;
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function GroupManager()
		{
			bloomFx = new FlxSprite();
			bloomFx.makeGraphic(FlxG.width / bloom, FlxG.height / bloom, 0, true);
			bloomFx.setOriginToCorner();
			bloomFx.scale.x = bloom;
			bloomFx.scale.y = bloom;
			bloomFx.antialiasing = true;
			bloomFx.blend = "screen";
			FlxG.camera.screen.scale.x = 1 / bloom;
			FlxG.camera.screen.scale.y = 1 / bloom;
			
			super();
			
			for (var i:int = 0; i < MAX_PEOPLE; i++)
			{
				//add(new Person(-100, -100)); //add people here
				add(new PersonManager());
			}
		}
		
		override public function update():void //update function
		{
			//sort("y", ASCENDING);
			sort("personY", ASCENDING);
			
			super.update();
		}
		
		override public function draw():void 
		{
			super.draw();
			//bloomFx.stamp(FlxG.camera.screen);
			//bloomFx.draw();
		}
		
		public function spawnPerson(X:int, Y:int, isOnList:Boolean):void
		{
			//if(getFirstAvailable(Person)) Person(getFirstAvailable(Person)).reset(X, Y);
			for (var i: int = 0; i < MAX_PEOPLE; i++)
			{
				if (!members[i].members[0].alive)
				{
					Person(members[i].members[0]).isOnList = isOnList;
					members[i].members[0].reset(X, Y);
					i = MAX_PEOPLE + 1;
				}
			}
		}
	}
}


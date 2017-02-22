package
{
	import org.flixel.*;

	public class PersonManager extends FlxGroup
	{
		//------------------------------------------DECLARATIONS---------------------------------------------
		//private const MAX_PEOPLE:int = 100;
		public var personY:Number = 0;
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function PersonManager()
		{
			super();
			
			add(new Person(-100, -100)); //members[0] is the person
			add(new Emote(-100, -100)); //members[1] is the emote
		}
		
		override public function update():void //update function
		{
			personY = members[0].y;
			
			if (members[0].emoteValue != 0)
			{
				members[1].emotionValue = members[0].emoteValue;
				members[1].reset(members[0].x - 4, members[0].y - 32);
				members[0].emoteValue = 0;
			}
			
			if (Emote(members[1]).alive)
			{
				members[1].x = members[0].x - 4;
				members[1].y = members[0].y - 44;
			}
			
			super.update();
		}
		
		public function spawnPerson(X:int, Y:int):void
		{
			Person(members[0]).reset(X, Y);
		}
	}
}


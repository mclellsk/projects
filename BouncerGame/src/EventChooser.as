package
{
	import org.flixel.*;
 
	public class EventChooser extends FlxGroup
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//this class's purpose is to fire off random background events (such as a car driving down the street or people walking on the sidewalk)
		//------------------------------------------DECLARATIONS---------------------------------------------
		private var actionCounter:Number = 0;
		private var light:Light;
		private var light2:Light;
		private var car:Car;
		
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function EventChooser()
		{
			super();
			light = new Light(0, 0, Registry.darkness, 1, 0xfffb85, 1, 1);
			light2 = new Light(0, 0, Registry.darkness, 1, 0xfffb85, 1, 1);
			car = new Car();
			add(car); //members[0] will be a car
			add(light);
			add(light2);
		}
		
		override public function update():void //update function
		{
			actionCounter = actionCounter + FlxG.elapsed;
			
			if (actionCounter > Math.random() * 17 + 3)
			{
				actionCounter = 0;
				members[0].resetCar(Math.random() * 2);
			}
			
			light.x = car.x + 15;
			light.y = car.y + 25;
			light2.x = car.x + 36;
			light2.y = car.y + 49;
			
			super.update();
		}
	}
}


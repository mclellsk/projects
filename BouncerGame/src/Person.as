package
{
	import org.flixel.*;
 
	public class Person extends FlxSprite
	{	
		//---------------------------------------CURRENT OBJECTIVES------------------------------------------
		//1. Generate a desire value for rejected people who want to get into the club
		//------------------------------------------DECLARATIONS---------------------------------------------
		[Embed(source = '../data/caught1.mp3')] private var soundCaught1:Class;
		[Embed(source = '../data/caught2.mp3')] private var soundCaught2:Class;
		[Embed(source = '../data/caught3.mp3')] private var soundCaught3:Class;
		[Embed(source = '../data/wrong1.mp3')] private var soundWrong1:Class;
		[Embed(source = '../data/wrong2.mp3')] private var soundWrong2:Class;
		[Embed(source = '../data/wrong3.mp3')] private var soundWrong3:Class;
		[Embed(source = '../data/fail1.mp3')] private var soundFail1:Class;
		[Embed(source = '../data/fail2.mp3')] private var soundFail2:Class;
		[Embed(source = '../data/fail3.mp3')] private var soundFail3:Class;
		[Embed(source = '../data/punch1.mp3')] private var soundPunch1:Class;
		[Embed(source = '../data/punch2.mp3')] private var soundPunch2:Class;
		[Embed(source = '../data/punch3.mp3')] private var soundPunch3:Class;
		
		[Embed(source = "../data/Person.png")] public var personSprite:Class; //base person image
		[Embed(source = "../data/Person_African.png")] public var personSprite2:Class;
		[Embed(source = "../data/Person_Lady.png")] public var personSprite3:Class;
		[Embed(source = "../data/Person_Asian.png")] public var personSprite4:Class;
		private var isInLine:Boolean = true; //if true, person will follow the line logic
		private var isMoving:Boolean = true; //this means that the line is currently moving forwards
		private var isSelectable:Boolean = true; //clickable
		public var isOnList:Boolean = false;
		private var stoppedTrigger:Boolean = false;
		private var actionCounter:Number = 0;
		private var targetSpeed:int = 30; //person will try to match this speed
		private var shirtColour:int;
		private var pantsColour:int;
		private var hairColour:int;
		private const ENTRANCE_POSITION:int = 16 * 16; //the location of the door, if a person has gotten past this point,
														//then they're considered accepted
		private const ENTRANCE_THRESHOLD:int = ENTRANCE_POSITION - 2.5 * 16; //The distance from the door where people will be automatically denied
		private const DOOR_Y:int = 10 * 16 - 4; //the y position of the door
		private var doorY:int = DOOR_Y; //the person's perceived y position of the door (this usually differs from the official y position by a few pixels)
		
		private var clothingDesign:String = new String("");
		private var clothingItem:String = new String("");
		public var clothingDescription:Clothing;
		public var clothingList:Array = new Array();
		public var clickCandidate:Boolean = false;
		public var clickConfirmed:Boolean = false;
		public var emoteValue:int = 0;
		public var generateRandomEmote:Boolean = true;
		private var occurOnce:Boolean = false;
		private var emoteCountdown:Number = -1;
		private var emotePoint:int;
		private var animState:int = 0; //0 - normal, 1 - mad, 2 - surprised
		private var desperation:int = 0; //0 - normal, 1 - slow exit, 2 - slow backwards exit, 3 - full-on dash
		private var dirOverride:Boolean = false; //override animation direction
		private var isDashing:Boolean = false; //is rushing the door
		private var isFlying:Boolean = false;
		
		//----------------------------------------CREATE FUNCTION--------------------------------------------
		public function Person(X: int, Y: int):void //X and Y define starting position of the player
		{
			super(X, Y); //x and y position of the person
			
			//makeGraphic(16, 16, 0xff00FF00, true);
			//loadGraphic(personSprite2, true, true, 32, 48, true);
			
			//Adjust size
			offset.x = width/2;
			offset.y = height;
			width = 8;
			height = 16;
			offset.x = offset.x - width/2;
			offset.y = offset.y - height;
			
			//origin.x = 10;
			//origin.y = 45;
			
			drag.x = 100;
			drag.y = 15;
			maxVelocity.x = 40; //maximum speed in the x direction
			maxVelocity.y = 40; //maximum speed in the y direction
			
			//Animations
			addAnimation("idle", [0]);
			addAnimation("mad", [3]);
			addAnimation("surprise", [6]);
			addAnimation("walk", [1, 0, 2, 0], 6, true);
			addAnimation("walkmad", [4, 3, 5, 3], 12, true);
			addAnimation("walksurprise", [7, 6, 8, 6], 12, true);
			play("walk");
			
			resetAttributes();
			
			kill();
		}
		
		override public function update():void //update function
		{
			//------------------------------------------ANIMATIONS-----------------------------------------------
			if (velocity.x == 0 && !isFlying)
			{
				switch(animState)
				{
					case 0: play("idle"); break;
					case 1: play("mad"); break;
					case 2: play("surprise"); break;
				}
			}
			else if(!isFlying)
			{
				switch(animState)
				{
					case 0: play("walk"); break;
					case 1: play("walkmad"); break;
					case 2: play("walksurprise"); break;
				}
			}
			//-------------------------------------------MOVEMENT------------------------------------------------
			if (velocity.x > 0 && !dirOverride) facing = RIGHT;
			if (velocity.x < 0 && !dirOverride) facing = LEFT;
			
			if (isInLine)
			{
				if (isMoving) //if the line is flowing, people walk from left to right
				{
					if (!solid) solid = true; //these conditions should probably be true for the line logic to hold
					if (stoppedTrigger) stoppedTrigger = false;
					if (immovable) immovable = false;
					
					if (velocity.x < targetSpeed) acceleration.x = 20; //accelerate until target speed is reached
					else acceleration.x = 0;
				}
				else //if the line is stopped, people slide in and stop when they collide with another person
				{
					if (!stoppedTrigger && x < ENTRANCE_POSITION + 8 && x > ENTRANCE_THRESHOLD && checkCombinationMatch() && isSelectable && Registry.difficulty == 0)
					{
						acceleration.y = 0;
						
						alpha = 1;
						clickCandidate = false;
						Registry.isSelecting = false;
						
						getCaught(); //if a person in the line is caught, they're taken out of the line
					}
					else if (!stoppedTrigger) stoppedTrigger = true; //this ensures that people farther back don't deny themselves when they walk up to the bouncer
					acceleration.x = 0;
					
					if (velocity.x == 0)
					{
						if(onScreen()) immovable = true; //this ensures that a person who comes to a stop will not get pushed forwards
					}
				}
				
				if (y < doorY && velocity.x != 0 && isSelectable) //people will waddle up and down slightly while moving towards the door
				{
					acceleration.y = 5;
				}
				else if (velocity.x != 0 && isSelectable)
				{
					acceleration.y = -5;
				}
				else //if they're not walking towards the door, they won't move up and down
				{
					acceleration.y = 0;
					velocity.y = 0;
				}
				
				if (Registry.isStopped && isMoving) isMoving = false;
				else if (!Registry.isStopped && !isMoving) isMoving = true;
				
				if (x > ENTRANCE_POSITION && x < ENTRANCE_POSITION + 8 && Registry.isStopped && !isFlying) //if a person is stopped in front of the bouncer, they'll go immobile to provide a place for more people to stop
				{
					x = ENTRANCE_POSITION;
					velocity.x = 0;
					if(onScreen()) immovable = true;
				}
				
				if (y > doorY + 4) y = doorY + 4; //y variance can't be too large, line should still be single-file for the most part
				if (y < doorY - 4) y = doorY - 4;
				
				//no input on loss
				if (Registry.timeElapsed != 0)
				{
					if (!isMoving && FlxG.mouse.x > x - 5 && FlxG.mouse.x < x + width + 5 && FlxG.mouse.y > y - 30 && FlxG.mouse.y < y + height && !Registry.isSelecting && isSelectable && x < ENTRANCE_POSITION + 8) //highlight logic
					{
						alpha = 0.5;
						clickCandidate = true;
						Registry.isSelecting = true;
						//trace(Clothing(this.clothingList[0]).ClothingItem + "," + Clothing(this.clothingList[0]).ClothingDesign);
						//trace(Clothing(this.clothingList[1]).ClothingItem + "," + Clothing(this.clothingList[1]).ClothingDesign);
						//trace(this.checkCombinationMatch());
					}
					else if ((isMoving || FlxG.mouse.x < x - 5 || FlxG.mouse.x > x + width + 5 || FlxG.mouse.y < y - 30 || FlxG.mouse.y > y + height) && (Registry.isSelecting && clickCandidate))
					{
						alpha = 1;
						clickCandidate = false;
						Registry.isSelecting = false;
					}
					else if (FlxG.mouse.justPressed() && clickCandidate && Registry.isSelecting && x < ENTRANCE_POSITION + 8/* && checkCombinationMatch()*/)
					{
						clickCandidate = false;
						Registry.isSelecting = false;
						alpha = 1;
						getCaught();
					}
				}
				if (acceleration.x == 0 && velocity.x < 1) velocity.x = 0;
				
				if (immovable && x < 0) Registry.leftScreenWarning = true;
				
				if (x > Registry.SWFWIDTH)
				{
					kill(); //not needed once they're off the screen
					
					if (checkCombinationMatch() && Registry.timeElapsed > 0)
					{
						Registry.mistakes++; //you let someone in who wasn't supposed to be there
						playSound(2);
					}
					else Registry.accepted++;
				}
			}
			else if (isDashing)
			{
				if (!isFlying && !flickering)
				{
					if (velocity.x < 0) velocity.x = 0;
					maxVelocity.x = 200;
					acceleration.x = 400;
					if (y > DOOR_Y + 8) acceleration.y = -300;
					else if (y < DOOR_Y) acceleration.y = 300;
					else if (y < DOOR_Y && y < DOOR_Y - 8)
					{
						acceleration.y = 0;
						velocity.y = 0;
					}
				}
				if (x > ENTRANCE_POSITION && x < ENTRANCE_POSITION + 8 && Registry.isStopped && !isFlying && !flickering)
				{
					isFlying = true;
					acceleration.y = 0;
					velocity.y = 0;
					offset.y = offset.y - 16;
					offset.x = offset.x - 8;
					y = Registry.player.y;
					x = Registry.player.x - 3.5*16;
					acceleration.x = 0;
					velocity.x = -100;
					drag.x = 100;
					angle = -90;
					animState = 2;
					play("surprise");
					Registry.player.play("punch", true);
					FlxG.shake(0.01, 0.1, null, true, 1);
					playSound(3);
				}
				else if (isFlying && velocity.x == 0)
				{
					isFlying = false;
					flicker(1);
				}
				else if (!isFlying && velocity.x == 0 && !flickering && angle == -90)
				{
					kill();
					Registry.accepted++;
				}
			}
			else
			{
				actionCounter = actionCounter + FlxG.elapsed; //bring the action counter up
				if (actionCounter > 1.5 && actionCounter < 2 && !isFlying)
				{
					if (acceleration.x != -20)
					{
						acceleration.x = -20;
						velocity.y = (Math.random() * 5 + 25) * (Math.pow( -1, Math.floor(Math.random() * 2)));
					}
				}
				else if (actionCounter > 2 && !occurOnce && !isFlying)
				{
					if (Math.floor(Math.random() * 2) == 1)
					{
						emoteValue = 4;
						animState = 1;
					}
					occurOnce = true;
				}
				else if (actionCounter >= 4 && actionCounter < 5 && checkCombinationMatch() && desperation > 0 && animState == 1)
				{
					velocity.x = -maxVelocity.x / 2;
					velocity.y = 0;
				}
				else if (actionCounter > 5 && actionCounter < 7 && checkCombinationMatch() && desperation > 1 && animState == 1)
				{
					velocity.x = -maxVelocity.x / 4;
					velocity.y = 0;
					dirOverride = true;
					facing = RIGHT;
				}
				else if (actionCounter > 7 && checkCombinationMatch() && desperation > 2 && animState == 1 && !Registry.isStopped && !isDashing)
				{
					//TODO: mad 4, where they charge back in at the bouncer
					isDashing = true;
				}
				
				if (!onScreen()) 
				{
					kill();
					if (!checkCombinationMatch() || isDashing)
					{
						Registry.mistakes++; //you turned down or lost a legitimate customer, or one ran by you while you weren't looking
						playSound(2);
					}
					else if (!isDashing) Registry.accepted++;
				}
			}
			
			//if (emoteCountdown > 0) emoteCountdown = emoteCountdown - FlxG.elapsed;
			//if (emoteCountdown <= 0 && emoteCountdown > -1)
			if(x > emotePoint && emotePoint > 0)
			{
				if (generateRandomEmote)
				{
					switch(int(Math.random() * 6))
					{
						case 0: 
							break;
						case 1: 
							break;
						case 2: 
							break;
						case 3: emoteValue = 5;
							break;
						case 4: emoteValue = 7;
							break;
						case 5: if (checkCombinationMatch()) emoteValue = 6;
							break;
						case 6: if (checkCombinationMatch()) emoteValue = 6;
							break;
						default: break;
					}
				generateRandomEmote = false;
				}
				//emoteCountdown = -1;
				emotePoint = -1;
			}
			
			super.update();
		}
		
		override public function reset(X:Number,Y:Number):void
		{
			super.reset(X, Y);
			resetAttributes();
			generateAppearance(isOnList);
		}
		
		public function resetAttributes():void
		{
			//Reset all these values
			angle = 0;
			maxVelocity.x = 40;
			isFlying = false;
			isDashing = false;
			dirOverride = false;
			desperation = Math.random() * 4;
			emotePoint = Math.random() * Registry.SWFWIDTH - (5 * 16) + (1 * 16);
			generateRandomEmote = true;
			animState = 0;
			emoteCountdown = -1;
			drag.x = 0;
			actionCounter = 0;
			isSelectable = true;
			immovable = false;
			isInLine = true;
			
			//Randomly Select Person Sprite
			switch(int(Math.random()*3))
			{
				case 0: loadGraphic(personSprite2, true, true, 32, 48, true); break;
				case 1: loadGraphic(personSprite3, true, true, 32, 48, true); break;
				case 2: loadGraphic(personSprite4, true, true, 32, 48, true); break;
				default: loadGraphic(personSprite, true, true, 32, 48, true); break;
			}
			
			//Set sprite collision box
			offset.x = width/2;
			offset.y = height;
			width = 8;
			height = 16;
			offset.x = offset.x - width/2;
			offset.y = offset.y - height;
			
			//Set Velocity
			velocity.x = Math.random() * maxVelocity.x/2 + maxVelocity.x/2;
			velocity.y = Math.random() * 11 - 5;
			y = y + (Math.random() * 17 - 8);
			doorY = DOOR_Y + (Math.random() * 17 - 8);
		}
		
		private function replaceColorOnClothing(value:int, baseColor:uint, baseColor2:uint):void
		{
			switch(value)
			{
				case 0: 
					replaceColor(baseColor, 0xffF61F0F); //red-orange
					replaceColor(baseColor2, 0xffB91205); //dark red-orange
					clothingDesign = DesignTypes.RED;
					break;
				case 1: 
					replaceColor(baseColor, 0xff032F00); //green
					replaceColor(baseColor2, 0xff022200); //dark green
					clothingDesign = DesignTypes.GREEN;
					break;
				case 2: 
					replaceColor(baseColor, 0xff00466F); //blue
					replaceColor(baseColor2, 0xff012941); //dark blue
					clothingDesign = DesignTypes.BLUE;
					break;
				case 3: 
					replaceColor(baseColor, 0xffEA9900); //gold
					replaceColor(baseColor2, 0xffA46C00); //dark gold
					clothingDesign = DesignTypes.GOLD;
					break;
				case 4: 
					replaceColor(baseColor, 0xffF400CF); //magenta
					replaceColor(baseColor2, 0xffD2007F); //dark magenta
					clothingDesign = DesignTypes.MAGENTA;
					break;
				default: 
					break;
			}
		}
		
		public function generateTop():void
		{
			//Set Clothing
			shirtColour = Math.random() * Colors.COUNT;
			clothingItem = ClothingTypes.SHIRT;
			replaceColorOnClothing(shirtColour, 0xff602552, 0xff3D1333);
			clothingDescription = new Clothing(clothingItem, clothingDesign);
			clothingList.push(clothingDescription);
		}
		
		public function generateBottom():void
		{
			//Set Pants
			pantsColour = Math.random() * Colors.COUNT;
			clothingItem = ClothingTypes.PANTS;
			replaceColorOnClothing(pantsColour, 0xff436025, 0xff2C4016);
			clothingDescription = new Clothing(clothingItem, clothingDesign);
			clothingList.push(clothingDescription);
		}
		
		public function generateHair():void
		{
			//Set Pants
			hairColour = Math.random() * Colors.COUNT;
			switch(hairColour) //0 to 5
			{
				case 0: //black
					replaceColor(0xff499A03, 0xff474747);
					replaceColor(0xff1D3F00, 0xff252525);
					replaceColor(0xff142705, 0xff0E0E0E);
					break;
				case 1: //orange
					replaceColor(0xff499A03, 0xffFFE56C);
					replaceColor(0xff1D3F00, 0xffEA9900);
					replaceColor(0xff142705, 0xffA46C00);
					break;
				case 2: //brown
					replaceColor(0xff499A03, 0xffC96D19);
					replaceColor(0xff1D3F00, 0xff713600);
					replaceColor(0xff142705, 0xff311700);
					break;
				case 3: //red
					replaceColor(0xff499A03, 0xffFF8E3C);
					replaceColor(0xff1D3F00, 0xffF61F0F);
					replaceColor(0xff142705, 0xffB91205);
					break;
				case 4: //magenta
					replaceColor(0xff499A03, 0xffFF84E1);
					replaceColor(0xff1D3F00, 0xffF400CF);
					replaceColor(0xff142705, 0xffD2007F);
					break;
				case 5: //white
					replaceColor(0xff499A03, 0xffF8F8F8);
					replaceColor(0xff1D3F00, 0xffDDDDDD);
					replaceColor(0xff142705, 0xff8D8D8D);
					break;
				default: 
					break;
			}
		}
		
		public function generateAppearance(isOnList:Boolean):void
		{
			//Empty the clothing list on reset
			clothingList.splice(0);
			clothingDesign = "";
			clothingItem = "";
				
			//This forces the person to be wearing a clothing set that is on the list, randomizes selection
			if (isOnList)
			{
				var checkListItem:int = Math.random() * Registry.checkList.length;
				
				for (var i:int = 0; i < Combination(Registry.checkList[checkListItem]).comboList.length; i++)
				{
					var clothingTemp:Clothing = Clothing(Combination(Registry.checkList[checkListItem]).comboList[i]);
					if (clothingTemp.ClothingItem == ClothingTypes.PANTS)
					{
						clothingItem = clothingTemp.ClothingItem;
						clothingDesign = clothingTemp.ClothingDesign;
						switch (clothingDesign)
						{
							case DesignTypes.BLUE:
								replaceColorOnClothing(Colors.BLUE, 0xff436025, 0xff2C4016);
								break;
							case DesignTypes.MAGENTA:
								replaceColorOnClothing(Colors.MAGENTA, 0xff436025, 0xff2C4016);
								break;
							case DesignTypes.GREEN:
								replaceColorOnClothing(Colors.GREEN, 0xff436025, 0xff2C4016);
								break;
							case DesignTypes.RED:
								replaceColorOnClothing(Colors.RED_ORANGE, 0xff436025, 0xff2C4016);
								break;
							case DesignTypes.GOLD:
								replaceColorOnClothing(Colors.GOLD, 0xff436025, 0xff2C4016);
								break;
						}
						clothingDescription = new Clothing(clothingItem, clothingDesign);
						clothingList.push(clothingDescription);
					}
					else if (clothingTemp.ClothingItem == ClothingTypes.SHIRT)
					{
						clothingItem = clothingTemp.ClothingItem;
						clothingDesign = clothingTemp.ClothingDesign;
						switch (clothingDesign)
						{
							case DesignTypes.BLUE:
								replaceColorOnClothing(Colors.BLUE, 0xff602552, 0xff3D1333);
								break;
							case DesignTypes.MAGENTA:
								replaceColorOnClothing(Colors.MAGENTA, 0xff602552, 0xff3D1333);
								break;
							case DesignTypes.GREEN:
								replaceColorOnClothing(Colors.GREEN, 0xff602552, 0xff3D1333);
								break;
							case DesignTypes.RED:
								replaceColorOnClothing(Colors.RED_ORANGE, 0xff602552, 0xff3D1333);
								break;
							case DesignTypes.GOLD:
								replaceColorOnClothing(Colors.GOLD, 0xff602552, 0xff3D1333);
								break;
						}
						clothingDescription = new Clothing(clothingItem, clothingDesign);
						clothingList.push(clothingDescription);
					}
				}
				
				var hasShirt:Boolean = false;
				var hasPants:Boolean = false;
				
				//Clothing check, if piece is not in combo, randomize clothing.
				for (var j:int = 0; j < clothingList.length; j++)
				{
					if (Clothing(clothingList[j]).ClothingItem == ClothingTypes.SHIRT)
					{
						hasShirt = true;
					}
					if (Clothing(clothingList[j]).ClothingItem == ClothingTypes.PANTS)
					{
						hasPants = true;
					}
				}
				if (!hasShirt)
				{
					generateTop();
				}
				if (!hasPants)
				{
					generateBottom();
				}
				
			}
			else
			{	
				//If it should not be forced to be on the list, randomize pairing (can potentially lead to match, may want to control this)
				generateTop();
				generateBottom();
			}
			
			generateHair();
		}
		
		public function checkCombinationMatch():Boolean
		{
			var comboMatch:Boolean = false;
			var combo:Combination;
			
			for (var i:int = 0; i < Registry.checkList.length; i++)
			{
				combo = Combination(Registry.checkList[i]);
				comboMatch = true;
				for (var j:int = 0; j < combo.comboList.length; j++)
				{
					if (!comboMatch)
					{
						break;
					}
					for (var k:int = 0; k < this.clothingList.length; k++)
					{
						if (Clothing(combo.comboList[j]).ClothingItem == Clothing(this.clothingList[k]).ClothingItem && Clothing(combo.comboList[j]).ClothingDesign == Clothing(this.clothingList[k]).ClothingDesign)
						{
							break;
						}
						else if (k == this.clothingList.length - 1)
						{
							comboMatch = false;
							break;
						}
					}
				}
				if (comboMatch)
				{
					return true;
				}
			}
			return false;
		}
		
		public function getCaught():void
		{
			Registry.player.play("pointforward", true);
			isSelectable = false;
			isInLine = false;
			solid = false;
			//flicker(3);
			acceleration.x = 0;
			drag.x = 100;
			drag.y = 15;
			velocity.y = 0;
			acceleration.x = 0;
			acceleration.y = 0;
			if (Math.floor(Math.random() * 3) == 2)	animState = 2;
			if (checkCombinationMatch())
			{
				emoteValue = 1;
				playSound(0);
			}
			else
			{
				emoteValue = (Math.random() * 2) + 2;
				playSound(1);
			}
			emoteCountdown = -1;
			generateRandomEmote = false;
			
			//kill();
		}
		
		private function playSound(n:int):void //n in this case would be the type of sound to play
		{
			switch(n) //0 - caught, 1 - wrong catch, 2 - fail, 3 - punch
			{
				case 0:
					switch(Math.floor(Math.random()*3))
					{
						case 0: FlxG.play(soundCaught1);
							break;
						case 1: FlxG.play(soundCaught2);
							break;
						case 2: FlxG.play(soundCaught3);
							break;
					}
					break;
				case 1:
					switch(Math.floor(Math.random()*3))
					{
						case 0: FlxG.play(soundWrong1);
							break;
						case 1: FlxG.play(soundWrong2);
							break;
						case 2: FlxG.play(soundWrong3);
							break;
					}
					break;
				case 2:
					switch(Math.floor(Math.random()*3))
					{
						case 0: FlxG.play(soundFail1);
							break;
						case 1: FlxG.play(soundFail2);
							break;
						case 2: FlxG.play(soundFail3);
							break;
					}
					break;
				case 3:
					switch(Math.floor(Math.random()*3))
					{
						case 0: FlxG.play(soundPunch1);
							break;
						case 1: FlxG.play(soundPunch2);
							break;
						case 2: FlxG.play(soundPunch3);
							break;
					}
					break;
			}
		}
	}
}
package  
{
	import org.flixel.*;
	
	public class Light extends FlxSprite
	{
		[Embed(source = "../data/light.png")]
		
		private var LightImageClass:Class;
		private var darkness:FlxSprite;
		
		public function Light(x:Number, y:Number, darkness:FlxSprite, alpha:Number, color:uint, scalex:Number, scaley:Number):void
		{
			super(x, y, LightImageClass);
			this.darkness = darkness;
			this.blend = "screen";
			this.alpha = alpha;
			this.color = color;
			this.scale.x = scalex;
			this.scale.y = scaley;
		}
		
		override public function draw():void
		{
			var screenXY:FlxPoint = getScreenXY();
			
			darkness.stamp(this, screenXY.x - this.width / 2, screenXY.y - this.height / 2);
		}
	}

}
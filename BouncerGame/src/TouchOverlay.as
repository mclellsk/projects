package  
{
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import org.flixel.FlxSprite;
	import flash.display.*;
	
	public class TouchOverlay extends Sprite
	{
		
		public function TouchOverlay(width:Number, height:Number)
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			var s:Sprite = new Sprite()
			s.graphics.beginFill(0xFFFFFF, 1);
			s.graphics.drawRect(0, 0, width, height);
			s.graphics.endFill();
			addChild(s);
			
			s.addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			s.addEventListener(TouchEvent.TOUCH_END, onRelease);
		}
		
		
		private function onRelease(e:TouchEvent):void
		{
			
		}
		
		private function onBegin(e:TouchEvent):void 
		{
			
		}
	}
}
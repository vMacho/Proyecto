package  {
	
	import flash.display.SimpleButton;
		import flash.events.MouseEvent;
		import flash.utils.Timer;
	   import flash.events.TimerEvent;
		import flash.display.MovieClip;
	public class FIRE_attack extends SimpleButton {
		
		public var cooldown:int;
		public var cooldownTimer:Timer;
		public function FIRE_attack() {
			// constructor code
			cooldown=2000;
			cooldownTimer = new Timer(cooldown,1);
			cooldownTimer.addEventListener( TimerEvent.TIMER_COMPLETE, function(){}, false, 0, true );
			addEventListener(MouseEvent.CLICK,pulsado);
		}
		
		function pulsado(e:MouseEvent):void
		{
			if(cooldownTimer.running==false)
			{
			trace("FUEGOOO");
				
			}
		 cooldownTimer.start();
		}
	}
	
}

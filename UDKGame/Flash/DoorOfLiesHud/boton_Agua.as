package  {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
    import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class boton_Agua extends MovieClip {
		
		public var cooldown:int;
		public var cooldownTimer:Timer;
		public var accionado:Boolean;
		public function boton_Agua() {
			stop();
			accionado=false;
			cooldown=2000;
			cooldownTimer = new Timer(cooldown,1);
			cooldownTimer.addEventListener( TimerEvent.TIMER_COMPLETE,function(){}, false, 0, true );
			cooldownTimer.addEventListener( TimerEvent.TIMER, tiempoCompleto);
		 this.addEventListener(MouseEvent.MOUSE_OVER, mouse_over);
         this.addEventListener(MouseEvent.MOUSE_OUT, mouse_out);  
		 this.addEventListener(MouseEvent.CLICK, mouse_click);   
		}
		private function mouse_out(e:MouseEvent):void
		{
		 if(accionado==false)
         gotoAndStop(1);

		};
		private function mouse_over(e:MouseEvent):void
		{
		if(accionado==false)
         gotoAndStop(2);
		};
		private function mouse_click(e:MouseEvent):void
		{
		if(accionado==false)
			{
			gotoAndStop(3);
				
			accionado=true;
				
				//PRUEBA
				shoot_spell();
			}
		};
		private function shoot_spell()
		{
			if(accionado==true)
			{ 
			if(cooldownTimer.running==false)
				{
				trace("AGUA");
				
				}
			cooldownTimer.start();
			gotoAndStop(4);
			}
		}
		private function tiempoCompleto(e:TimerEvent):void
		{
			accionado=false;
			gotoAndStop(1);
			trace("entra");
		}


	}
	
}
package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.display.SimpleButton;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import Quests;
	
	public class close extends Boton 
	{
		private var mode:Boolean;
		private var activo:Boolean;
			
		public function close() {
			stop();
			mode=false;
			activo=false;
			this.addEventListener(MouseEvent.MOUSE_OVER, mouse_over);
			this.addEventListener(MouseEvent.MOUSE_OUT, mouse_out); 
			}
		
		
		
		override public function ControlaClick(event:TimerEvent):void
		{			
			PauseGame();
			if(activo==false)
			{
			gotoAndStop(2);
			activo=true;
				
			}
			else
			{
			gotoAndStop(1);
			activo=false;
				
			}
		}
		
		public function PauseGame()
		{
			
		}
		private function mouse_over(e:MouseEvent):void
		{
			if(activo==false)
			{
				gotoAndStop(4);
			}
		}
		private function mouse_out(e:MouseEvent):void
		{
			if(activo==false)
			{
				gotoAndStop(1);
			}
		}
		public function reiniciar()
		{
		gotoAndStop(1);
		activo=false;
		}
	}
}

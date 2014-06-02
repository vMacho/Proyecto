package  {
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	
	public class Boton extends MovieClip 
	{		
		private var espera:Timer;
		
		public function Boton() 
		{
			addEventListener(MouseEvent.CLICK, OnClick);
			
		}
		
		public function OnClick(event:MouseEvent): void
		{
			espera = new Timer(200, 1); //Delay para el click
			espera.addEventListener(TimerEvent.TIMER, ControlaClick);
			espera.start();
			
		}
		
		public function ControlaClick(event:TimerEvent):void{}	
		
	}
	
}

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
	
	public class BotonMainMenu extends Boton 
	{	
		public function BotonMainMenu() 
		{
		}
				
		override public function ControlaClick(event:TimerEvent):void
		{
			ExternalInterface.call("MainMenu");
		}
	}
}

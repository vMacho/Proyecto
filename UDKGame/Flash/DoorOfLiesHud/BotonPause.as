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
	
	public class BotonPause extends Boton 
	{			
		private var mode:Boolean;

		public function BotonPause() 
		{
            SetLabel("Pause");
			mode = false;
		}
				
		override public function ControlaClick(event:TimerEvent):void
		{			
			if(!mode)
			{
				SetLabel("Resume");
				MovieClip(parent).getChildByName("_HUDHealth").visible = mode;
			}
			else
			{
				SetLabel("Pause");
				MovieClip(parent).getChildByName("_HUDHealth").visible = mode;
			}
			
			mode = !mode;
			
			ExternalInterface.call("PauseGameControl", mode);
		}
	}
	
}

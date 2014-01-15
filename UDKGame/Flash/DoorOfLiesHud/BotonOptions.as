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
	
	public class BotonOptions extends Boton 
	{			
		public function BotonOptions() {
            SetLabel("Options");
		}
		
		override public function ConfigureLabel():void 
		{
            label = new TextField();
            label.autoSize = TextFieldAutoSize.CENTER;
			label.x += 150;
			label.y += 150;

            var format:TextFormat = new TextFormat();
            format.font = "Trajan Pro 3";
            format.color = 000;
            format.size = 50;

            label.defaultTextFormat = format;
            addChild(label);
        }
		
		override public function ControlaClick(event:TimerEvent):void
		{
			ExternalInterface.call("ShowOptions");
		}
	}
	
}


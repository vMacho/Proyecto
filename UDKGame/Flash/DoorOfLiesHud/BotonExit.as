﻿package  {	
	
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	
	public class BotonExit extends Boton 
	{					
		public function BotonExit() {
            SetLabel("Exit");
		}
		
		override public function ConfigureLabel():void 
		{
            label = new TextField();
            label.autoSize = TextFieldAutoSize.CENTER;
			label.x += 150;
			label.y += 375;

            var format:TextFormat = new TextFormat();
            format.font = "Trajan Pro 3";
            format.color = 000;
            format.size = 93;
			
            label.defaultTextFormat = format;
			label.embedFonts = true;
			addChild(label);
        }
		
		override public function ControlaClick(event:TimerEvent):void
		{
			ExternalInterface.call("ConsoleCommand", "quit");
		}
		
	}
	
}


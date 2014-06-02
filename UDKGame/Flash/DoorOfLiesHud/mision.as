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
	import BotonMision;
	
	public class mision extends Boton  {
		
		public var texto:String;
		public var click:Boolean;
		public var num:int;
		public var boton:BotonMision=new BotonMision();
		public function mision(text:String,n:int) {
			click=true;
			texto=text;
			mision_tit.text=texto;
			num=n;
			addChild(boton);
		
		}
		override public function ControlaClick(event:TimerEvent):void
		{			
			
			if(click==true)
			{
				
				(parent as Quests).DetallesMision(texto,num);
				
				click=false;
				//DesactivarOtrasMisiones();
			}
			else
			{
				(parent as Quests).DetallesMision("0",num);
				click=true;
			}
		}
		public function DesactivarOtrasMisiones()
		{
			for(var value:String in (parent as Quests).questes)
			{
				((parent as Quests).questes[value] as mision).click=true;
			}

		}		
	}
}

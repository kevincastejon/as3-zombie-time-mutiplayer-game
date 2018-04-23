package gameGUI {
	
	import flash.display.Sprite;
	import fl.controls.Button;
	import fl.events.ComponentEvent;
	import flash.events.Event;
	import flash.desktop.NativeApplication;
	import piooas3Tools.air.nativeOps.ProcessLauncher;

	
	
	public class GameOverScreen extends Sprite {
		
		private var btnRetry:Button;
		private var btnQuit:Button;
		
		public function GameOverScreen() {
			btnRetry=s_btnRetry;
			btnQuit=s_btnQuit;
			btnRetry.addEventListener(ComponentEvent.BUTTON_DOWN, retryHandler);
			btnQuit.addEventListener(ComponentEvent.BUTTON_DOWN, quitHandler);
		}
		
		private function retryHandler(e:Event):void{
		ProcessLauncher.rebootApp();
		}
		private function quitHandler(e:Event):void{
		stage.nativeWindow.dispatchEvent(new Event(Event.CLOSE));
		NativeApplication.nativeApplication.exit();
		}
	}
	
}

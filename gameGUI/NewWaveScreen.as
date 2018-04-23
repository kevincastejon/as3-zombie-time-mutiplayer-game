package gameGUI {
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	
	public class NewWaveScreen extends Sprite {
		
		
		public function NewWaveScreen() {
		
		}
		
		public function setWave(num:int):void{
		s_txtfld.text="Wave "+num;
		}
	}
	
}

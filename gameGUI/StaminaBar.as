package gameGUI {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	
	
	public class StaminaBar extends Sprite {
		
		private var maskMC:MovieClip;
		private var innerStaminaBar:MovieClip;
		
		public function StaminaBar() {
		this.maskMC=s_mask;
		this.innerStaminaBar=s_innerStaminaBar;
		innerStaminaBar.mask=maskMC;
		}
		
		public function setStaminaPercent(value:Number):void{
		maskMC.width=200*value;
		}
	}
	
}

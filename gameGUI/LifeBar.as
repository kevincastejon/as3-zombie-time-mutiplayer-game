package gameGUI {
	
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import fl.motion.Color;
	
	
	public class LifeBar extends Sprite {
		
		private var maskMC:MovieClip;
		private var innerLifeBar:MovieClip;
		private var colorA:Color=new Color(0,1,0);
		private var colorB:Color=new Color(1,0,0);
		private var value:Number=1;
		public function LifeBar() {
		this.maskMC=s_mask;
		this.innerLifeBar=s_innerLifeBar;
		innerLifeBar.mask=maskMC;
		setLifePercent(value);
		}
		public function setColors(colorA:uint,colorB:uint):void{
		this.colorA.color=colorA;
		this.colorB.color=colorB;
		setLifePercent(value);
		}
		public function setLifePercent(value:Number):void{
		innerLifeBar.transform.colorTransform=Color.interpolateTransform(colorB,colorA,value);
		maskMC.width=200*value;
		this.value=value;
		}
	}
	
}

package engine {
	
	import flash.display.MovieClip;
	import engine.anims.*;
	
	public class MapElement extends MovieClip {
		
		
		public function MapElement() {
			// constructor code
		}
		public function getImpactAnim():OneShotAnim{
		return(new DustAnim());
		}
		public function getImpactAudioName():String{
		return("impactWood01");
		}
	}
	
}

package utils {
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import engine.actors.Player;
	
	public class Calculator {

		public static var hero:Player;
		
		public function Calculator() {
			// constructor code
		}
		
		public static function getPanForHero(objectSource:DisplayObject):Number{
		return((objectSource.x-hero.x)/500);
		}
		public static function getVolumeForHero(objectSource:DisplayObject):Number{
		var vol:Number=1-(Point.distance(new Point(objectSource.x,objectSource.y),new Point(hero.x,hero.y))/1000);
		if(vol<0)vol=0;
		return(vol);
		}
	}
	
}

package piooas3Tools.fl.utils {
	import flash.geom.Point;
	
	public class MathSup {

		public function MathSup() {
			// constructor code
		}
		
		public static function getAngle(pointA:Point,pointB:Point,angleType:String="degree"):Number{
		var distanceX : Number = pointB.x - pointA.x;
		var distanceY : Number = pointB.y - pointA.y;
		var angleInRadians : Number = Math.atan2(distanceY, distanceX);
		var angleInDegrees : Number = angleInRadians * (180 / Math.PI);
			if(angleType==AngleType.DEGREE)return(angleInDegrees);
			else return(angleInRadians);
		}
		public static function degreeToRadian(degrees:Number):Number{
		return(degrees * Math.PI / 180);
		}
		public static function radianToDegree(radians:Number):Number{
		return(radians * 180 / Math.PI);
		}
		public static function randomRange(minNum:Number, maxNum:Number):Number
		{
		return (Math.floor(Math.random() * (maxNum - minNum + 1)) + minNum);
		}
	}
	
}

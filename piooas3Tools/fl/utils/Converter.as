package piooas3Tools.fl.utils {
	
	public class Converter {

		public function Converter() {
			// constructor code
		}
		
		public static function HEXColorToCSSColor(color:uint):String
		{
		return "#" + color.toString(16).toUpperCase();
		}			

	}
	
}

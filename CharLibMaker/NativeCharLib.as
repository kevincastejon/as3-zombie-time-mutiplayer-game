package  {
	
	import flash.display.MovieClip;
	
	
	public class NativeCharLib extends MovieClip {
		
		
		public function NativeCharLib() {
			// constructor code
		}
		
		public static function getChar(charName:String):MovieClip{
			if(charName=="charA"){
			return(new CharA());
			}
			else if(charName=="charB"){
			return(new CharB());
			}
			else if(charName=="charC"){
			return(new CharC());
			}
			else if(charName=="charD"){
			return(new CharD());
			}
			else return(null);
		}
	}
	
}

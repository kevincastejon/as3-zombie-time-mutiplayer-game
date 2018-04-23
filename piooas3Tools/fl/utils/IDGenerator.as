package piooas3Tools.fl.utils {
	
	public class IDGenerator {

		private static var dico:Object=new Object();
		
		public function IDGenerator() {
			// constructor code
		}
		
		public static function addChannel(channelName:String):void{
		if(dico[channelName]==undefined)dico[channelName]=0;
		}
		
		public static function removeChannel(channelName:String):void{
		if(dico[channelName]!=undefined)dico[channelName]=undefined;
		}
		public static function channelExists(channelName:String):Boolean{
		return(dico.hasOwnProperty(channelName));
		}
		public static function getNextID(channelName:String):int{
		var retInt:int=dico[channelName];
		dico[channelName]++;
		return(retInt);
		}
		public static function getCurrentID(channelName:String):int{
		return(dico[channelName]);
		}
		
		public static function resetChannel(channelName:String):void{
		dico[channelName]=0;
		}
		

	}
	
}

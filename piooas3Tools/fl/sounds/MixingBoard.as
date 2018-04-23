package piooas3Tools.fl.sounds {
	import piooas3Tools.fl.utils.IterableTools;
	
	public class MixingBoard {
		
		
	internal static const IDGeneratorChannelName:String="MixingBoardChannel";
	
		private static var tracks:Vector.<Track>=new Vector.<Track>();
		internal static var mainTrack:Track=new Track("master");
	
		public static function addTrack(name:String,volume:Number=1):void{
		tracks.push(new Track(name,volume));
		}
		
		public static function addAudio(audio:Audio,trackName:String):void{
		(IterableTools.getElementByProperties(tracks,[["name",trackName]]) as Track).addAudio(audio);
		audio.mainVolume=MixingBoard.mainTrack.getVolume();
		}
		
		public static function removeTrack(trackName:String):void{
		tracks.splice(tracks.indexOf(IterableTools.getElementByProperties(tracks,[["name",trackName]])),1);
		}

	}
	
}

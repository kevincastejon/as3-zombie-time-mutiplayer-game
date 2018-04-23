package piooas3Tools.fl.sounds {
	import flash.events.Event;
	import piooas3Tools.fl.utils.IterableTools;
	import flash.media.Sound;
	import flash.net.URLRequest;
	
	public class Magneto {

		private static var audios:Vector.<Audio>=new Vector.<Audio>();
		private static var motherAudios:Vector.<Audio>=new Vector.<Audio>();
		
		public function Magneto() {
		
		}

		public static function loadAudio(soundUrl:String,nameID:String):void{
		var motherAudio:Audio=new Audio(new Sound(new URLRequest(soundUrl)));
		motherAudio.nameID=nameID;
		motherAudios.push(motherAudio);
		}
		
		public static function playAudio(nameID:String,trackName:String,volume:Number=1,pan:Number=0,loop:Boolean=false):int{
		var audio:Audio=new Audio(null,volume,pan);
		audio.motherAudio=getMotherAudioByNameID(nameID);
		audio.nameID=nameID;
		audios.push(audio);
		MixingBoard.addAudio(audio,trackName);
		audio.loop=loop;
		audio.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		audio.play();
		return(audio.id);
		}
		public static function stopAudio(audioID:int):void{
		var audio:Audio=IterableTools.getElementByProperties(audios,[["id",audioID]]);
		audio.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		audio.stop();
		audios.splice(audios.indexOf(audio,1),1);
		}
		public static function stopAudiosByNameID(nameID:String):void{
		var max:int=audios.length;
			for(var i:int=0;i<max;i++){
				if(audios[i].nameID==nameID){
				stopAudio(audios[i].id);
				max--;
				}
			}
		}
		private static function soundCompleteHandler(e:Event):void{
		var audio:Audio=e.currentTarget as Audio;
			if(audio.loop)audio.play();
			else{
			audio.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			audios.splice(audios.indexOf(audio,1),1);
			}
		
		}
		private static function getMotherAudioByNameID(nameID:String):Audio{
		var max:int=motherAudios.length;
			for(var i:int=0;i<max;i++){
			if(motherAudios[i].nameID==nameID)return(motherAudios[i]);
			}
		return(null);
		}

	}
	
}

package piooas3Tools.fl.sounds {
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import piooas3Tools.fl.utils.IDGenerator;
	import flash.events.EventDispatcher;
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	
	public class Audio extends EventDispatcher{
	
	internal var mainVolume:Number=1;
	internal var trackVolume:Number=1;
	internal var loop:Boolean;	
	internal var nameID:String;
	internal var motherAudio:Audio;
	internal var _id:int;
	internal var sound:Sound;
	private static var firstAudioCreated:Boolean;
	private var soundChannel:SoundChannel;
	private var lastPosition:Number=0;
	private var volume:Number=1;
	private var pan:Number=0;
	private var _url:String;
	
		
		public function Audio(sound:Sound,volume:Number=1,pan:Number=0) {
		
			if(!firstAudioCreated){
			Audio.firstAudioCreated=true;
			IDGenerator.addChannel(MixingBoard.IDGeneratorChannelName);
			}
		_id=IDGenerator.getNextID(MixingBoard.IDGeneratorChannelName);
		this.sound=sound;
		this.volume=volume;
		this.pan=pan;
		if(sound)sound.addEventListener(Event.COMPLETE,handler);
		else if(motherAudio)_url=motherAudio.sound.url;
		}
		private function handler(e:Event):void{
		_url=sound.url;
		}
		public function play():void{
		if(motherAudio)soundChannel=motherAudio.sound.play(lastPosition);
		else soundChannel=sound.play(lastPosition);
			if(soundChannel){
			soundChannel.addEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
			applySoundTransform();
			}
			//else trace("probleme de carte son ou bien 32 canaux utilisés");
		}
		public function stop():void{
		soundChannel.removeEventListener(Event.SOUND_COMPLETE, soundCompleteHandler);
		soundChannel.stop();
		soundChannel=null;
		lastPosition=0;
		}
		public function pause():void{
		lastPosition=soundChannel.position;
		stop(); 
		}
		public function setVolume(value:Number):void{
		volume=value;
		applySoundTransform();
		}
		public function setPan(value:Number):void{
		pan=value;
		applySoundTransform();
		}
		public function get url():String{
		return(_url);
		}
		public function get id():int{
		return(_id);
		}
		private function applySoundTransform():void{
		if(soundChannel)soundChannel.soundTransform=new SoundTransform((volume*trackVolume)*mainVolume,pan);
		//if(soundChannel)trace(soundChannel.soundTransform.volume,soundChannel.soundTransform.pan);
		}
		private function soundCompleteHandler(e:Event):void{
		dispatchEvent(e);
		}

	}
	
}

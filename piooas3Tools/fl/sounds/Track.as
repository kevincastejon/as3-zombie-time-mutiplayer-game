package piooas3Tools.fl.sounds {
	
	public class Track {

	private var _name:String="";
	private var audios:Vector.<Audio>=new Vector.<Audio>();
	private var volume:Number=1;
	
		public function Track(name:String,volume:Number=1) {
		this._name=name;
		this.volume=volume;
		}
		
		internal function addAudio(audio:Audio):void{
		audios.push(audio);
		audio.trackVolume=volume;
		}
		public function setVolume(value:Number):void{
		volume=value;
		var max:int=audios.length;
			for(var i:int=0;i<max;i++){
			audios[i].trackVolume=volume;
			}
		}
		
		public function get name():String{
		return(_name);
		}
		public function getVolume():Number{
		return(volume);
		}

	}
	
}

package engine.actors {
	
	public class ActorState {

		public var actorType:int;
		public var id:int;
		public var posX:int;
		public var posY:int;
		public var rotation:int;
		public var life:int;
		
		public function ActorState(actorType:uint,id:uint,posX:int,posY:int,rotation:int,life:int) {
		this.actorType=actorType;this.id=id;this.posX=posX;this.posY=posY;this.rotation=rotation;this.life=life;
		}
		
		public function serialize():Array{
		return([actorType,id,posX,posY,rotation,life]);
		}
		
		public static function unserialize(state:Array):ActorState{
		return(new ActorState(state[0],state[1],state[2],state[3],state[4],state[5]));
		}
		public function toString():String{
		return(String("actorType:"+actorType+" id:"+id+" posX:"+posX+" posY:"+posY+" rotation:"+rotation+" life:"+life));
		}

	}
	
}

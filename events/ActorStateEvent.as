package events {
	import flash.events.Event;
	import engine.actors.ActorState;
	
	public class ActorStateEvent extends Event {

		public static const ACTOR_STATES:String="actorStates";

		public var actorStates:Vector.<ActorState>;
		public var playerID:int;
		public var lastInputID:int;
		
		public function ActorStateEvent(type:String,actorStates:Vector.<ActorState>,playerID:int,lastInputID:int,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.actorStates=actorStates;
		this.playerID=playerID;
		this.lastInputID=lastInputID;
		super(type,bubbles,cancelable);
		}

	}
	
}

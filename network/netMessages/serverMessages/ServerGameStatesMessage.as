package network.netMessages.serverMessages {
	import engine.actors.ActorState;
	
	public class ServerGameStatesMessage extends ServerMessage{
		
		public static const ACTOR_STATES:String="actorStates";
		
		public var actorStates:Vector.<ActorState>;
		public var lastInputID:int;
		
		public function ServerGameStatesMessage(type:String,actorStates:Vector.<ActorState>,lastInputID:int) {
		this.actorStates=actorStates;
		this.lastInputID=lastInputID;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.actorStates=[];
		msg.lastInputID=lastInputID;
		var max:int=actorStates.length;
			for(var i:int=0;i<max;i++){
			msg.actorStates.push(actorStates[i].serialize());
			}
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerGameStatesMessage{
		var states:Vector.<ActorState>=new Vector.<ActorState>();
		var max:int=msg.actorStates.length;
			for(var i:int=0;i<max;i++){
			states.push(ActorState.unserialize(msg.actorStates[i]));
			}
		return(new ServerGameStatesMessage(msg.type,states,msg.lastInputID));
		}

	}
	
}

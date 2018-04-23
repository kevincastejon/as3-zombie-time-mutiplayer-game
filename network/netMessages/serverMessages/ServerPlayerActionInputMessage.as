package network.netMessages.serverMessages {
	import engine.inputs.ActionInput;
	
	
	public class ServerPlayerActionInputMessage extends ServerPlayerMessage{
		
		public static const PLAYER_ACTION:String="playerAction";
		
		public var actionInput:ActionInput;
		
		public function ServerPlayerActionInputMessage(type:String,playerID:int,actionInput:ActionInput) {
		this.actionInput=actionInput;
		super(type,playerID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.actionInput=actionInput.serialize();
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerPlayerActionInputMessage{
		return(new ServerPlayerActionInputMessage(msg.type,msg.playerID,ActionInput.unserialize(msg.actionInput)));
		}

	}
	
}

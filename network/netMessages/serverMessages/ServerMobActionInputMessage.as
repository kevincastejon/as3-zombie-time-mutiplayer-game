package network.netMessages.serverMessages {
	import engine.inputs.ActionInput;
	
	
	public class ServerMobActionInputMessage extends ServerMobMessage{
		
		public static const MOB_ACTION:String="mobAction";
		
		public var actionInput:ActionInput;
		
		public function ServerMobActionInputMessage(type:String,mobID:int,actionInput:ActionInput) {
		this.actionInput=actionInput;
		super(type,mobID);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.actionInput=actionInput.serialize();
		return(msg);
		}
		
		public static function unserialize(msg:Object):ServerMobActionInputMessage{
		return(new ServerMobActionInputMessage(msg.type,msg.mobID,ActionInput.unserialize(msg.actionInput)));
		}

	}
	
}

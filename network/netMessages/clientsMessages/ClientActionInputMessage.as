package network.netMessages.clientsMessages {
	import engine.inputs.ActionInput;
	
	public class ClientActionInputMessage extends ClientMessage{
		
		public static const ACTION:String="action";
		
		public var actionInput:ActionInput;
		
		public function ClientActionInputMessage(type:String,actionInput:ActionInput) {
		this.actionInput=actionInput;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.actionInput=actionInput.serialize();
		return(msg);
		}
		
		public static function unserialize(msg:Object):ClientActionInputMessage{
		return(new ClientActionInputMessage(msg.type,ActionInput.unserialize(msg.actionInput)));
		}


	}
	
}

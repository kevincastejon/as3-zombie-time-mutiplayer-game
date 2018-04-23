package network.netMessages.clientsMessages {
	
	public class ClientChatMessage extends ClientMessage{
		
		public static const CHAT:String="chat";
		
		public var chat:String;
		
		public function ClientChatMessage(type:String,chat:String) {
		this.chat=chat;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.chat=chat;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ClientChatMessage{
		return(new ClientChatMessage(msg.type,msg.chat));
		}

	}
	
}

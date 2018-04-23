package network.netMessages.clientsMessages {
	
	public class ClientCharMessage extends ClientMessage{
		
		public static const SELECTED_CHARACTER:String="selectedCharacter";
		
		public var character:String;
		
		public function ClientCharMessage(type:String,character:String) {
		this.character=character;
		super(type);
		}
		
		public override function serialize():Object{
		var msg:Object=super.serialize();
		msg.character=character;
		return(msg);
		}
		
		public static function unserialize(msg:Object):ClientCharMessage{
		return(new ClientCharMessage(msg.type,msg.character));
		}

	}
	
}

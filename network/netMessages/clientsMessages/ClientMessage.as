package network.netMessages.clientsMessages {
	import network.netMessages.NetMessage;
	
	public class ClientMessage extends NetMessage {

		public static const READY:String="ready";
		public static const UNREADY:String="unready";
		public static const RETRY:String="retry";
		
		public function ClientMessage(type:String) {
		super(type);
		}
		public override function serialize():Object{
		return(super.serialize());
		}
		public static function unserialize(msg:Object):ClientMessage{
		return(new ClientMessage(msg.type));
		}

	}
	
}

package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class NetMessageEvent extends IDRelatedEvent {

		public static const INCOMING_MESSAGE:String="incomingMessage";

		public var netMessage:NetMessage;
		
		public function NetMessageEvent(type:String,netMessage:NetMessage,peerID:int=0,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.netMessage=netMessage;
		super(type,peerID,bubbles,cancelable);
		}

	}
	
}

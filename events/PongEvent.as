package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class PongEvent extends IDRelatedEvent {

		public static const CLIENT_PONG:String="clientPong";
		public static const SERVER_PONG:String="serverPong";

		public var time:Number;
		
		public function PongEvent(type:String,time:Number,peerID:int=0,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.time=time;
		super(type,peerID,bubbles,cancelable);
		}

	}
	
}

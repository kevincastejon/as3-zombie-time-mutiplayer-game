package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class IDRelatedEvent extends Event {

		public static const CLIENT_TIMED_OUT:String="clientTimedOut";
		public static const NEW_CLIENT_CONNECTING:String="newClientConnecting";

		
		public var id:int;
		
		public function IDRelatedEvent(type:String,id:int,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.id=id;
		super(type,bubbles,cancelable);
		}
		
		public override function clone():Event{
		return(new IDRelatedEvent(type,id,bubbles,cancelable));
		}

	}
	
}

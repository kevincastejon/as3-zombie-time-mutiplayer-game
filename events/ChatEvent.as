package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class ChatEvent extends Event {

		public static const CHAT:String="chat";

		public var chat:String;
		
		public function ChatEvent(type:String,chat:String,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.chat=chat;
		super(type,bubbles,cancelable);
		}

	}
	
}

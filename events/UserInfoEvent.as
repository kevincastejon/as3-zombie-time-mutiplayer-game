package events {
	import flash.events.Event;
	import network.netMessages.NetMessage;
	
	public class UserInfoEvent extends IDRelatedEvent {

		public static const NEW_CLIENT_CONNECTED:String="newClientConnected";

		public var nickName:String;
		public var color:uint;
		
		public function UserInfoEvent(type:String,nickName:String,color:uint,peerID:int=0,bubbles:Boolean=false,cancelable:Boolean=false) {
		this.nickName=nickName;
		this.color=color;
		super(type,peerID,bubbles,cancelable);
		}

	}
	
}

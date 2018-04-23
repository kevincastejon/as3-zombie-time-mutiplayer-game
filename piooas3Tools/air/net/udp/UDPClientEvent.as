package piooas3Tools.air.net.udp {
	import flash.events.Event;
	
	public class UDPClientEvent extends Event {
	
	public static const CONNECTED_TO_SERVER:String="connectedToServer";
	public static const CONNECTION_FAILED:String="connectionFailed";
	public static const SERVER_PONG:String="serverPong";
	public static const SERVER_TIMED_OUT:String="serverTimedOut";
	public static const SERVER_SENT_DATA:String="clientSentData";
		
		public var udpPeer:UDPPeer;
		public var udpDataInfo:UDPDataInfo;
	
		public function UDPClientEvent(type:String,udpPeer:UDPPeer, udpDataInfo:UDPDataInfo=null, bubbles:Boolean=false,cancelable:Boolean=false) {
			this.udpPeer=udpPeer;
			this.udpDataInfo=udpDataInfo;
			super(type,bubbles,cancelable);
		}
		

	}
	
}

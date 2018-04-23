package piooas3Tools.air.net.udp {
	import flash.events.Event;
	
	public class UDPServerEvent extends Event {
	
	public static const CLIENT_CONNECTED:String="clientConnected";
	public static const CLIENT_PONG:String="clientPong";
	public static const CLIENT_TIMED_OUT:String="clientTimedOut";
	public static const CLIENT_SENT_DATA:String="clientSentData";
		
		public var udpPeer:UDPPeer;
		public var udpDataInfo:UDPDataInfo;
	
		public function UDPServerEvent(type:String, udpPeer:UDPPeer, udpDataInfo:UDPDataInfo=null, bubbles:Boolean=false,cancelable:Boolean=false) {
			this.udpPeer=udpPeer;
			this.udpDataInfo=udpDataInfo;
			super(type,bubbles,cancelable);
		}
		

	}
	
}

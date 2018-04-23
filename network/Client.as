package network {
	
	import piooas3Tools.air.net.udp.UDPPeer;
	
	public class Client {

		public var id:int;
		public var udpPeer:UDPPeer;
		
		public function Client(id:int, udpPeer:UDPPeer) {
		this.id=id;
		this.udpPeer=udpPeer;
		}
		
	}
	
}

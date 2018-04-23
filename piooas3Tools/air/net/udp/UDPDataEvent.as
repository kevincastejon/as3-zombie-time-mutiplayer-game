package piooas3Tools.air.net.udp {
	import flash.events.Event;
	
	public class UDPDataEvent extends Event {
	
	public static const SENT:String="sent";
	public static const DELIVERED:String="delivered";
	public static const RETRIED:String="retried";
	public static const CANCELED:String="canceled";
		
		public function UDPDataEvent(type:String, bubbles:Boolean=false,cancelable:Boolean=false) {
			super(type,bubbles,cancelable);
		}
		
	}
	
}

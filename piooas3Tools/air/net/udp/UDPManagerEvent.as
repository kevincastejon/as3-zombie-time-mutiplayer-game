package piooas3Tools.air.net.udp {
	import flash.events.Event;
	
	public class UDPManagerEvent extends Event {
	
	internal static const SEND_DATA:String="sendData";
	public static const DATA_RECEIVED:String="dataReceived";
	public static const DATA_SENT:String="dataSent";
	public static const DATA_DELIVERED:String="dataDelivered";
	public static const DATA_RETRIED:String="dataRetried";
	public static const DATA_CANCELED:String="dataCanceled";
		
	private var _udpDataInfo:UDPDataInfo;
		
		public function UDPManagerEvent(type:String, udpDataInfo:UDPDataInfo, bubbles:Boolean=false,cancelable:Boolean=false) {
			this._udpDataInfo=udpDataInfo;
			super(type,bubbles,cancelable);
		}
		
		public function get udpDataInfo():UDPDataInfo{
		return(this._udpDataInfo);
		}

	}
	
}

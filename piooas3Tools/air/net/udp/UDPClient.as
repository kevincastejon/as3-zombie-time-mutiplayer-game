package piooas3Tools.air.net.udp {
	import flash.events.EventDispatcher;
	import piooas3Tools.air.TraceWindow;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.ErrorEvent;
	
	public class UDPClient extends EventDispatcher  {

		private var udpManager:UDPManager;
		private var udpServer:UDPPeer;
		private var serverPort:int;
		private var serverAddress:String;
		private var connected:Boolean;
		private var connecting:Boolean;
		
		public function UDPClient(localPort:int=-1,serverAddress:String=null,serverPort:int=-1) {
		udpManager=new UDPManager(-1);
		udpManager.initHiddenChannels();
		udpManager.initPeersFilter();
		udpManager.addEventListener(UDPManagerEvent.DATA_RECEIVED, receivedDataHandler);
		udpManager.addEventListener(UDPManagerEvent.DATA_CANCELED, cancelHandler);
		udpManager.addEventListener(UDPManagerEvent.DATA_RETRIED, retryHandler);
		udpManager.addEventListener(UDPManagerEvent.DATA_DELIVERED, deliveryHandler);
		udpManager.addEventListener(DatagramSocketDataEvent.DATA, classicDataSystemHandler);
		udpManager.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent){dispatchEvent(e)});
		if(localPort>-1)udpManager.bind(localPort);
		if(serverAddress!=null && serverPort>-1)connect(serverAddress,serverPort,localPort);
		}
		public function reset(removeChannels:Boolean=true){
			connecting=false;
			connected=false;
			if(udpServer)udpServer.close();
			udpServer=null;
			udpManager.closeHiddenChannels();
			udpManager.reset(removeChannels);
		}
		//connect to UDPServer
		public function connect(serverAddress:String,serverPort:int,localPort:int=-1){
		if(connected)reset(false);
		connecting=true;
		if(localPort>-1 && udpManager.bound==false)udpManager.bind(localPort);
		this.serverAddress=serverAddress;
		this.serverPort=serverPort;
		udpManager.send(UDPManager.UDPMRCC,{messageType:"newConnection"},serverAddress,serverPort);
		}
		//methods for adding, removing and accessing the channels
		public function addChannel(channelName:String, guarantiesDelivery:Boolean=false, maintainOrder:Boolean=false, retryTime:Number=30, cancelTime:Number=500):void{
		udpManager.addChannel(channelName,guarantiesDelivery,maintainOrder,retryTime,cancelTime);
		}
		public function removeChannel(channelName:String):void{
		udpManager.removeChannel(channelName);
		}
		public function getChannelByName(channelName:String):UDPChannel{
		return(udpManager.getChannelByName(channelName));
		}
		public function sendToServer(channelName:String,data:Object):UDPDataInfo{
		return(udpManager.send(channelName,data,serverAddress,serverPort));
		}
		public function sendToNonServerPeer(channelName:String,data:Object,peer:UDPPeer):UDPDataInfo{
		return(udpManager.send(channelName,data,peer.address,peer.port));
		}
		public function sendOutOfChannels(data:Object,remoteAddress:String,remotePort:int):void{	//send to one client
			udpManager.sendOutOfChannels(data,remoteAddress,remotePort);
		}
		
		//
		//private methods
		//
		
		private function receivedDataHandler(e:UDPManagerEvent){
		if(e.udpDataInfo.channelName==UDPManager.UDPMRCP && e.udpDataInfo.data.messageType=="ping"){
		//certainly do nothin
		}
		else{
			if(udpServer.address==e.udpDataInfo.remoteAddress && udpServer.port==e.udpDataInfo.remotePort){
			this.dispatchEvent(new UDPClientEvent(UDPClientEvent.SERVER_SENT_DATA,udpServer,e.udpDataInfo));
			}
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RECEIVED, e.udpDataInfo));
		}
		}
		private function cancelHandler(e:UDPManagerEvent){
			if(e.udpDataInfo.channelName==UDPManager.UDPMRCP && e.udpDataInfo.data.messageType=="ping"){
			this.dispatchEvent(new UDPClientEvent(UDPClientEvent.SERVER_TIMED_OUT, udpServer));
			reset();
			}
			else if(e.udpDataInfo.channelName==UDPManager.UDPMRCC && e.udpDataInfo.data.messageType=="newConnection"){
			this.dispatchEvent(new UDPClientEvent(UDPClientEvent.CONNECTION_FAILED, null));
			reset();
			}
			else
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_CANCELED, e.udpDataInfo));
		}
		private function classicDataSystemHandler(e:DatagramSocketDataEvent){
		this.dispatchEvent(e);		//redispatch classic datagramsocket event
		}
		private function retryHandler(e:UDPManagerEvent){
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RETRIED, e.udpDataInfo));
		}
		private function deliveryHandler(e:UDPManagerEvent){
			if(e.udpDataInfo.channelName==UDPManager.UDPMRCC && e.udpDataInfo.data.messageType=="newConnection"){
			udpServer=new UDPPeer(e.udpDataInfo.remoteAddress,e.udpDataInfo.remotePort);
			udpManager.addPeerToPeersFilter(udpServer);
			udpServer.listenToPing(pingTimerHandler);
			udpServer.startPingTimer();
			connecting=false;
			connected=true;
			this.dispatchEvent(new UDPClientEvent(UDPClientEvent.CONNECTED_TO_SERVER,udpServer));
			}
			else if(e.udpDataInfo.channelName==UDPManager.UDPMRCP && e.udpDataInfo.data.messageType=="ping"){
			udpServer.setPing(e.udpDataInfo.ping);
			this.dispatchEvent(new UDPClientEvent(UDPClientEvent.SERVER_PONG,udpServer));
			}
			else{
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_DELIVERED, e.udpDataInfo));
			}
		}
		private function pingTimerHandler(peer:UDPPeer){
		sendToServer(UDPManager.UDPMRCP,{messageType:"ping"});
		}

	}
	
}

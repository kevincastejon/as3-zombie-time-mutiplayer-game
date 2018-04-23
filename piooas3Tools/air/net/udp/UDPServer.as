package piooas3Tools.air.net.udp {
	import flash.events.EventDispatcher;
	import flash.events.DatagramSocketDataEvent;
	import piooas3Tools.fl.utils.IterableTools;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	
	
	public class UDPServer extends EventDispatcher {
		
		private var udpManager:UDPManager;
		private var peers:Vector.<UDPPeer>=new Vector.<UDPPeer>();		//clients
		private var started:Boolean;
		
		public function UDPServer(localPort:int=-1) {
		udpManager=new UDPManager(-1);
		udpManager.initHiddenChannels();
		udpManager.initPeersFilter();
		udpManager.addEventListener(UDPManagerEvent.DATA_RECEIVED, receivedDataHandler);
		udpManager.addEventListener(UDPManagerEvent.DATA_CANCELED, cancelHandler);
		udpManager.addEventListener(UDPManagerEvent.DATA_RETRIED, retryHandler);
		udpManager.addEventListener(UDPManagerEvent.DATA_DELIVERED, deliveryHandler);
		udpManager.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent){dispatchEvent(e)});
		udpManager.addEventListener(DatagramSocketDataEvent.DATA, classicDataSystemHandler);
		
		if(localPort>-1)start(localPort);
		}
		public function reset(removeChannels:Boolean=true){
			started=false;
			var max:int=peers.length;
				for(var i:int=0;i<max;i++){
				peers[i].close();
				udpManager.removePeerFromPeersFilter(peers[i]);
				}
			peers=new Vector.<UDPPeer>();
			udpManager.closeHiddenChannels();
			udpManager.reset(removeChannels);
		}
		public function start(localPort:int):void{
			if(started)reset(false);
			udpManager.bind(localPort);
			started=true;
			
		}
		//
		//public methods
		//
		//methods for adding,removing and accessing channel
		public function addChannel(channelName:String, guarantiesDelivery:Boolean=false, maintainOrder:Boolean=false, retryTime:Number=30, cancelTime:Number=500):void{
		udpManager.addChannel(channelName,guarantiesDelivery,maintainOrder,retryTime,cancelTime);
		}
		public function removeChannel(channelName:String):void{
		udpManager.removeChannel(channelName);
		}
		public function getChannelByName(channelName:String):UDPChannel{
		return(udpManager.getChannelByName(channelName));
		}
		//methods for accessing clients
		public function get numClients():int{
		return(peers.length);
		}
		public function getPeerAt(index:int):UDPPeer{
		return(peers[index]);
		}
		public function addWhiteAddress(address:String){
		udpManager.addWhiteAddress(address);
		}
		public function addBlackAddress(address:String){
		udpManager.addBlackAddress(address);
		}
		public function removeWhiteAddress(address:String){
		udpManager.removeWhiteAddress(address);
		}
		public function removeBlackAddress(address:String){
		udpManager.removeBlackAddress(address);
		}
		public function get whiteListLength():int{
		return(udpManager.whiteListLength);
		}
		public function get blackListLength():int{
		return(udpManager.blackListLength);
		}
		public function getWhiteAddressAt(index:int):String{
		return(udpManager.getWhiteAddressAt(index));
		}
		public function getBlackAddressAt(index:int):String{
		return(udpManager.getBlackAddressAt(index));
		}
		public function get whiteListEnabled():Boolean{
		return(udpManager.whiteListEnabled);
		}
		public function set whiteListEnabled(bool:Boolean){
		udpManager.whiteListEnabled=bool;
		}
		public function get blackListEnabled():Boolean{
		return(udpManager.blackListEnabled);
		}
		public function set blackListEnabled(bool:Boolean){
		udpManager.blackListEnabled=bool;
		}
		//sending methods
		public function sendToAll(channelName:String,data:Object):Vector.<UDPDataInfo>{		//sendToAllClients
		var max:int=peers.length;
			if(max==0)return(null);
		var ret:Vector.<UDPDataInfo>=new Vector.<UDPDataInfo>();
			for(var i:int=0;i<max;i++){
			ret.push(udpManager.send(channelName,data,peers[i].address,peers[i].port));
			}
		return(ret);
		}
		public function sendToClient(channelName:String,data:Object, peer:UDPPeer):UDPDataInfo{	//send to one client
		return(udpManager.send(channelName,data,peer.address,peer.port));
		}
		public function sendOutOfChannels(data:Object,remoteAddress:String,remotePort:int):void{	//send to one client
			udpManager.sendOutOfChannels(data,remoteAddress,remotePort);
		}			
		public function kickClient(peer:UDPPeer){
		peers.splice(peers.indexOf(peer),1);
		udpManager.removePeerFromPeersFilter(peer);
		peer.close();
		}
		public function banClient(peer:UDPPeer){
		addBlackAddress(peer.address);
		kickClient(peer);
		}
		//
		//private methods
		//
		
		//UDPManagerEvents listeners
		private function receivedDataHandler(e:UDPManagerEvent){
			var peer:UDPPeer;
			//trace("incoming data",e.udpDataInfo.channelName);
			if(e.udpDataInfo.channelName==UDPManager.UDPMRCC && e.udpDataInfo.data.messageType=="newConnection"){	//implements connection feature
				peer=new UDPPeer(e.udpDataInfo.remoteAddress,e.udpDataInfo.remotePort);
				peers.push(peer);
				udpManager.addPeerToPeersFilter(peer);
				peer.listenToPing(pingTimerHandler);
				peer.startPingTimer();
				this.dispatchEvent(new UDPServerEvent(UDPServerEvent.CLIENT_CONNECTED, peer));
				
			}
			else if(e.udpDataInfo.channelName==UDPManager.UDPMRCP && e.udpDataInfo.data.messageType=="ping"){			//implements ping feature
			//do nothing
			}
			else{
			peer=IterableTools.getElementByProperties(peers,[["address",e.udpDataInfo.remoteAddress],["port",e.udpDataInfo.remotePort]]);
				if(peer!=null){
				this.dispatchEvent(new UDPServerEvent(UDPServerEvent.CLIENT_SENT_DATA,peer,e.udpDataInfo));
				}
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RECEIVED, e.udpDataInfo));	//redispatch
			}
		}
		private function cancelHandler(e:UDPManagerEvent){
			if(e.udpDataInfo.channelName==UDPManager.UDPMRCP && e.udpDataInfo.data.messageType=="ping"){	//implements time out feature
			var peer:UDPPeer=IterableTools.getElementByProperties(peers,[["address",e.udpDataInfo.remoteAddress],["port",e.udpDataInfo.remotePort]]);
			kickClient(peer);
			this.dispatchEvent(new UDPServerEvent(UDPServerEvent.CLIENT_TIMED_OUT, peer));
			}
			else
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_CANCELED, e.udpDataInfo));		//redispatch
		}
		private function retryHandler(e:UDPManagerEvent){
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RETRIED, e.udpDataInfo));
		}
		private function deliveryHandler(e:UDPManagerEvent){
			if(e.udpDataInfo.channelName==UDPManager.UDPMRCP && e.udpDataInfo.data.messageType=="ping"){	//implements ping feature
			var peer:UDPPeer=IterableTools.getElementByProperties(peers,[["address",e.udpDataInfo.remoteAddress],["port",e.udpDataInfo.remotePort]]);
			peer.startPingTimer();
			peer.setPing(e.udpDataInfo.ping);
			this.dispatchEvent(new UDPServerEvent(UDPServerEvent.CLIENT_PONG,peer));
			}
			else{
			this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_DELIVERED, e.udpDataInfo));		//redispatch
			}
		}
		private function classicDataSystemHandler(e:DatagramSocketDataEvent){
		this.dispatchEvent(e);		//redispatch classic datagramsocket event
		}
				
		//ping handling event
		private function pingTimerHandler(peer:UDPPeer){
		sendToClient(UDPManager.UDPMRCP,{messageType:"ping"},peer);
		peer.stopPingTimer();
		}
	}
	
}

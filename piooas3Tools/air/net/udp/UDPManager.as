package piooas3Tools.air.net.udp {
	import flash.net.DatagramSocket;
	import flash.events.DatagramSocketDataEvent;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;
	import piooas3Tools.fl.utils.IterableTools;
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	import flash.events.ErrorEvent;
	
	public class UDPManager extends EventDispatcher {
		
	public static const UDPMRCP:String="UDPMRCP";	//UDPMANAGER_RESERVED_CHANNEL_PING
	public static const UDPMRCC:String="UDPMRCC";	//UDPMANAGER_RESERVED_CHANNEL_CONNECTION
		
	private var _UDPSocketIPv4:DatagramSocket;
	private var _UDPSocketIPv6:DatagramSocket;
		
	private var whiteList:Vector.<String>=new Vector.<String>();
	private var blackList:Vector.<String>=new Vector.<String>();
	private var _whiteListEnabled:Boolean;
	private var _blackListEnabled:Boolean;
		
	private var _nextudpDataUniqueID:int=0;
	private var _receivedIDs:Vector.<String>=new Vector.<String>();	//To not get message many times (when the sent receipt is lost)
	
	private var _channels:Vector.<UDPChannel>=new Vector.<UDPChannel>();
		
	private var peersFilter:Vector.<UDPPeer>;		//if a UDPServer has instanciate UDPManager a peersFilter will be created, only messages coming from one of those peers will be treated
	private var _pingChannel:UDPChannel;			//Implemented for UDPServer
	private var _connectionChannel:UDPChannel;		//and UDPClient
		
		public function UDPManager(localPort:int=-1) {
		if(localPort>-1)bind(localPort);
		}

		public function reset(removeChannels:Boolean=true):void{
			if(_UDPSocketIPv4){
				_UDPSocketIPv4.removeEventListener( DatagramSocketDataEvent.DATA, receiveDataHandler );
				_UDPSocketIPv4.close();
				_UDPSocketIPv4=null;
			}
			if(_UDPSocketIPv6){
				_UDPSocketIPv6.removeEventListener( DatagramSocketDataEvent.DATA, receiveDataHandler );
				_UDPSocketIPv6.close();
				_UDPSocketIPv6=null;
			}
			if(removeChannels){
				while(_channels.length>0){
					removeChannel(_channels[0].name);
				}
			}
		}
		
		public function bind(localPort:int):void{
			reset(false);
			_UDPSocketIPv4=new DatagramSocket();
			_UDPSocketIPv4.addEventListener( DatagramSocketDataEvent.DATA, receiveDataHandler );
			_UDPSocketIPv4.bind(localPort,"0.0.0.0");
			_UDPSocketIPv4.receive();
			_UDPSocketIPv6=new DatagramSocket();
			_UDPSocketIPv6.addEventListener( DatagramSocketDataEvent.DATA, receiveDataHandler );
			_UDPSocketIPv6.bind(localPort,"::");
			_UDPSocketIPv6.receive();
		}
		
		public function addChannel(channelName:String, guarantiesDelivery:Boolean=false, maintainOrder:Boolean=false, retryTime:Number=30, cancelTime:Number=500):void{
		if(IterableTools.getElementByProperties(_channels,[["name",channelName]])==null){
		var channel:UDPChannel=new UDPChannel(channelName,maintainOrder,guarantiesDelivery,retryTime,cancelTime);
		channel.addEventListener(UDPManagerEvent.SEND_DATA, sendDataFromChannel);
		channel.addEventListener(UDPManagerEvent.DATA_DELIVERED, deliveredNotifForward);
		channel.addEventListener(UDPManagerEvent.DATA_RETRIED, retryNotifForward);
		channel.addEventListener(UDPManagerEvent.DATA_CANCELED, cancelNotifForward);
		_channels.push(channel);
		}
		else throw new Error("channelName "+channelName+" already used");
		}

		public function removeChannel(channelName:String):void{
		var channel:UDPChannel=getChannelByName(channelName);
		channel.removeEventListener(UDPManagerEvent.SEND_DATA, sendDataFromChannel);
		channel.removeEventListener(UDPManagerEvent.DATA_DELIVERED, deliveredNotifForward);
		channel.removeEventListener(UDPManagerEvent.DATA_RETRIED, retryNotifForward);
		channel.removeEventListener(UDPManagerEvent.DATA_CANCELED, cancelNotifForward);
		channel.close();
		_channels.splice(_channels.indexOf(channel),1);
		}
		
		private function deliveredNotifForward(e:UDPManagerEvent){
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_DELIVERED,e.udpDataInfo));
		}
		
		private function retryNotifForward(e:UDPManagerEvent){
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RETRIED,e.udpDataInfo));
		}
		
		private function cancelNotifForward(e:UDPManagerEvent){
		
		if(e.udpDataInfo.channelName==UDPManager.UDPMRCP){
		var max:int=_receivedIDs.length;
			for(var i:int=0;i<max;i++){
			var ar:Array=_receivedIDs[i].split(",");
			if(ar[0]==e.udpDataInfo.remoteAddress){
			_receivedIDs.splice(i,1);
			i--;max--;
			}
			}
		}
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_CANCELED,e.udpDataInfo));
		}
		
		private function receiveDataHandler(e:DatagramSocketDataEvent):void{
		var udpData: Object;
		try 
		{ 
		udpData = JSON.parse(e.data.readUTFBytes(e.data.bytesAvailable));
		e.data.position=0;
		var ID:int;
			if(udpData.hasOwnProperty("UDPMSID") && udpData.hasOwnProperty("UDPMCN") && udpData.hasOwnProperty("UDPMRA")){
			ID=udpData.UDPMSID;
			
			var bool:Boolean=true;
				if(whiteListEnabled && whiteList.length>0){
					if(whiteList.indexOf(e.srcAddress)>-1)bool=false;
				}
				else if(blackListEnabled && blackList.length>0){
					if(blackList.indexOf(e.srcAddress)==-1)bool=false;
				}
				else bool=true;	//No IP restriction
				
				if(peersFilter!=null && udpData.UDPMCN!=UDPManager.UDPMRCC && IterableTools.getElementByProperties(peersFilter,[["address",e.srcAddress],["port",e.srcPort]])==null)bool=false;
				
				if(bool){
					if(_receivedIDs.indexOf(e.srcAddress+","+ID)==-1){
					_receivedIDs.push(e.srcAddress+","+ID);
						if(_receivedIDs.length==999)_receivedIDs.shift();
					this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_RECEIVED,new UDPDataInfo(udpData.UDPMCN,e.srcAddress,e.srcPort,udpData.data,ID)));
					}
					else trace("already received");
					if(udpData.UDPMRA){
					classicSend({UDPManagerDataReceiptID:ID,UDPMCN:udpData.UDPMCN},e.srcAddress,e.srcPort);		//Send receipt
					}
				}
			}
			else if(udpData.hasOwnProperty("UDPManagerDataReceiptID") && udpData.hasOwnProperty("UDPMCN")){
			ID=udpData.UDPManagerDataReceiptID;
			
			var channel:UDPChannel;
				if(udpData.UDPMCN==UDPManager.UDPMRCP)
				channel=_pingChannel;
				else if(udpData.UDPMCN==UDPManager.UDPMRCC)
				channel=_connectionChannel;
				else
				channel = getChannelByName(udpData.UDPMCN);
			
				if(channel!=null)channel.getReceipt(ID);
			}
			else{
			this.dispatchEvent(e);
			}
		} 
		catch (err:Error) 
		{ 
		e.data.position=0;
		this.dispatchEvent(e);
		} 
		 
		
		}
		
		public function send(channelName:String,udpData:Object,remoteAddress:String,remotePort:int):UDPDataInfo{
			
			var channel:UDPChannel;
				if(channelName==UDPManager.UDPMRCP)
				channel=_pingChannel;
				else if(channelName==UDPManager.UDPMRCC)
				channel=_connectionChannel;
				else
				channel=getChannelByName(channelName);
				
				if(channel!=null){
				var udpDataInf:UDPDataInfo=new UDPDataInfo(channelName,remoteAddress,remotePort,udpData,getNextUniqueID());
				channel.addDataToBuffer(udpDataInf);
				return(udpDataInf);
				}
				else
				throw new Error("Channel :"+channelName+" not registered, use addChannel method first");
		}
		
		public function sendOutOfChannels(data:Object,remoteAddress:String,remotePort:int):void{
			classicSend(data,remoteAddress,remotePort);
			
		}
		public function addWhiteAddress(address:String){
		whiteList.push(address);
		}
		public function addBlackAddress(address:String){
		blackList.push(address);
		}
		public function removeWhiteAddress(address:String){
		whiteList.splice(whiteList.indexOf(address),1);
		}
		public function removeBlackAddress(address:String){
		blackList.splice(blackList.indexOf(address),1);
		}
		public function get whiteListLength():int{
		return(whiteList.length);
		}
		public function get blackListLength():int{
		return(blackList.length);
		}
		public function getWhiteAddressAt(index:int):String{
		return(whiteList[index]);
		}
		public function getBlackAddressAt(index:int):String{
		return(blackList[index]);
		}
		public function get whiteListEnabled():Boolean{
		return(_whiteListEnabled);
		}
		public function set whiteListEnabled(bool:Boolean){
		_whiteListEnabled=bool;
		}
		public function get blackListEnabled():Boolean{
		return(_blackListEnabled);
		}
		public function set blackListEnabled(bool:Boolean){
		_blackListEnabled=bool;
		}
		public function get bound():Boolean{
		return(_UDPSocketIPv4.bound);
		}
		internal function initPeersFilter(){
		peersFilter=new Vector.<UDPPeer>();
		}
		internal function addPeerToPeersFilter(udpPeer:UDPPeer){
		peersFilter.push(udpPeer);
		}
		internal function removePeerFromPeersFilter(udpPeer:UDPPeer){
		peersFilter.splice(peersFilter.indexOf(udpPeer),1);
		}
		internal function initHiddenChannels(){
		_pingChannel=new UDPChannel(UDPManager.UDPMRCP,true,true,1000,10000);
		_connectionChannel=new UDPChannel(UDPManager.UDPMRCC,true,false,1000,10000);
		_pingChannel.addEventListener(UDPManagerEvent.SEND_DATA, sendDataFromChannel);
		_pingChannel.addEventListener(UDPManagerEvent.DATA_DELIVERED, deliveredNotifForward);
		_pingChannel.addEventListener(UDPManagerEvent.DATA_RETRIED, retryNotifForward);
		_pingChannel.addEventListener(UDPManagerEvent.DATA_CANCELED, cancelNotifForward);
		_connectionChannel.addEventListener(UDPManagerEvent.SEND_DATA, sendDataFromChannel);
		_connectionChannel.addEventListener(UDPManagerEvent.DATA_DELIVERED, deliveredNotifForward);
		_connectionChannel.addEventListener(UDPManagerEvent.DATA_RETRIED, retryNotifForward);
		_connectionChannel.addEventListener(UDPManagerEvent.DATA_CANCELED, cancelNotifForward);
		}
		internal function closeHiddenChannels(){
		_pingChannel.removeEventListener(UDPManagerEvent.SEND_DATA, sendDataFromChannel);
		_pingChannel.removeEventListener(UDPManagerEvent.DATA_DELIVERED, deliveredNotifForward);
		_pingChannel.removeEventListener(UDPManagerEvent.DATA_RETRIED, retryNotifForward);
		_pingChannel.removeEventListener(UDPManagerEvent.DATA_CANCELED, cancelNotifForward);
		_connectionChannel.removeEventListener(UDPManagerEvent.SEND_DATA, sendDataFromChannel);
		_connectionChannel.removeEventListener(UDPManagerEvent.DATA_DELIVERED, deliveredNotifForward);
		_connectionChannel.removeEventListener(UDPManagerEvent.DATA_RETRIED, retryNotifForward);
		_connectionChannel.removeEventListener(UDPManagerEvent.DATA_CANCELED, cancelNotifForward);
		}
		private function sendDataFromChannel(e:UDPManagerEvent){
		var data:Object={UDPMSID:e.udpDataInfo.ID, UDPMCN:e.udpDataInfo.channelName, UDPMRA:e.currentTarget.guarantiesDelivery, data:e.udpDataInfo.data};
		classicSend(data,e.udpDataInfo.remoteAddress,e.udpDataInfo.remotePort);
		this.dispatchEvent(new UDPManagerEvent(UDPManagerEvent.DATA_SENT,e.udpDataInfo));
		}
		
		private function classicSend(udpData:Object, remoteAddress:String, remotePort:int){
			
		var ba:ByteArray=new ByteArray();
		ba.writeUTFBytes(JSON.stringify(udpData));
			try 
				{ 
				if(remoteAddress.match(/\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.|$)){4}\b/)!=null)
			this._UDPSocketIPv4.send(ba,0,0,remoteAddress,remotePort);
			else if(remoteAddress.match(/^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$/)!=null)
			this._UDPSocketIPv6.send(ba,0,0,remoteAddress,remotePort);
				} 
				catch (err:Error) 
				{ 
				this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"sendCriticalFail"));
				}
			
		}

		private function getNextUniqueID():int{
		var unID:int=_nextudpDataUniqueID;
			if(_nextudpDataUniqueID==9999)_nextudpDataUniqueID=0;
			else _nextudpDataUniqueID++;
		return(unID);
		}

		public function get numChannels():int{
		return(_channels.length);
		}
		public function getChannelAt(num:int):UDPChannel{
		return(_channels[num]);
		}
		public function getChannelByName(channelName:String):UDPChannel{
		var max:int=_channels.length;
			for(var i:int=0;i<max;i++){
				if(_channels[i].name==channelName)return(_channels[i]);
			}
		return(null);
		}
		public static function getBroadcastAddresses():Vector.<String>{
			var nis:Vector.<NetworkInterface>=NetworkInfo.networkInfo.findInterfaces();
			var ret:Vector.<String>=new Vector.<String>();
			var max:int=nis.length;
			for(var i:int=0;i<max;i++){
				var max2:int=nis[i].addresses.length;
				for(var j:int=0;j<max2;j++){
					if(nis[i].addresses[j].broadcast!="")ret.push(nis[i].addresses[j].broadcast);
				}
			}
			return(ret);
		}
	}
	
}

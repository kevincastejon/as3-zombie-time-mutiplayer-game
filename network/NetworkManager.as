package network {
	import flash.events.EventDispatcher;
	import piooas3Tools.air.net.udp.UDPClient;
	import piooas3Tools.air.net.udp.UDPServer;
	import piooas3Tools.air.net.udp.UDPServerEvent;
	import piooas3Tools.air.net.udp.UDPClientEvent;
	import network.netMessages.NetMessage;
	import piooas3Tools.air.net.udp.UDPDataInfo;
	import network.netMessages.clientsMessages.ClientPlayerInfoMessage;
	import events.SimpleEvent;
	import events.NetMessageEvent;
	import events.PongEvent;
	import events.IDRelatedEvent;
	import piooas3Tools.fl.utils.IterableTools;
	import utils.IDGeneratorChannels;
	import network.netMessages.serverMessages.ServerPlayerCharMessage;
	import network.netMessages.serverMessages.ServerGameStatesMessage;
	import piooas3Tools.fl.utils.IDGenerator;

	
	public class NetworkManager extends EventDispatcher {

		private var udpClient:UDPClient;
		private var udpServer:UDPServer;
		private var clients:Vector.<Client>=new Vector.<Client>();
		
		private var connectingClients:Vector.<Client>=new Vector.<Client>();
				
		private var playersUniqueID:int;
		
		private var isServer:Boolean;
		
		public function NetworkManager() {
		
		}
		
		public function startServer(listeningPort:int):UDPServer{
		isServer=true;
		udpServer=new UDPServer(listeningPort);
		udpServer.addEventListener(UDPServerEvent.CLIENT_CONNECTED, serverEventHandler);
		udpServer.addEventListener(UDPServerEvent.CLIENT_PONG, serverEventHandler);
		udpServer.addEventListener(UDPServerEvent.CLIENT_SENT_DATA, serverEventHandler);
		udpServer.addEventListener(UDPServerEvent.CLIENT_TIMED_OUT, serverEventHandler);
		return(udpServer);
		}
		
	
		public function startClient(listeningPort:int=-1,serverIp:String=null,serverPort:int=-1):UDPClient{
		udpClient=new UDPClient(listeningPort,serverIp,serverPort);
		udpClient.addEventListener(UDPClientEvent.CONNECTED_TO_SERVER, clientEventHandler);
		udpClient.addEventListener(UDPClientEvent.CONNECTION_FAILED, clientEventHandler);
		udpClient.addEventListener(UDPClientEvent.SERVER_PONG, clientEventHandler);
		udpClient.addEventListener(UDPClientEvent.SERVER_SENT_DATA, clientEventHandler);
		udpClient.addEventListener(UDPClientEvent.SERVER_TIMED_OUT, clientEventHandler);
		return(udpClient);
		}
		
		public function connectClient(serverAddress:String,serverPort:int,localPort:int=-1):void{
			udpClient.connect(serverAddress,serverPort,localPort);
		}
		
		public function sendToClient(id:int,netMessage:NetMessage,reliableMode:String):UDPDataInfo{
		return(udpServer.sendToClient(reliableMode+id,netMessage.serialize(),IterableTools.getElementByProperties(clients,[["id",id]]).udpPeer));
		}
		public function sendToAllClients(netMessage:NetMessage,reliableMode:String,excludesId:Array=null):Vector.<UDPDataInfo>{
		var max:int=clients.length;
		var retVec:Vector.<UDPDataInfo>=new Vector.<UDPDataInfo>();
			for(var i:int=0;i<max;i++){
			var bool:Boolean=true;
				if(excludesId)
				{
				var maxExcl:int=excludesId.length;
					for(var j:int;j<maxExcl;j++){
					if(excludesId[j]==clients[i].id)bool=false;
					}
				}
			if(bool)retVec.push(sendToClient(clients[i].id,netMessage,reliableMode));
			}
		return(retVec);
		}
		public function sendToServer(netMessage:NetMessage,reliableMode:String):UDPDataInfo{
		return(udpClient.sendToServer(reliableMode,netMessage.serialize()));
		}
		public function close(){
		clients=new Vector.<Client>();
			if(isServer){
			udpServer.removeEventListener(UDPServerEvent.CLIENT_CONNECTED, serverEventHandler);
			udpServer.removeEventListener(UDPServerEvent.CLIENT_PONG, serverEventHandler);
			udpServer.removeEventListener(UDPServerEvent.CLIENT_SENT_DATA, serverEventHandler);
			udpServer.removeEventListener(UDPServerEvent.CLIENT_TIMED_OUT, serverEventHandler);
			udpServer.reset();	//automatically remove channels
			}
			else{
			udpClient.removeEventListener(UDPClientEvent.CONNECTED_TO_SERVER, clientEventHandler);
			udpClient.removeEventListener(UDPClientEvent.CONNECTION_FAILED, clientEventHandler);
			udpClient.removeEventListener(UDPClientEvent.SERVER_PONG, clientEventHandler);
			udpClient.removeEventListener(UDPClientEvent.SERVER_SENT_DATA, clientEventHandler);
			udpClient.removeEventListener(UDPClientEvent.SERVER_TIMED_OUT, clientEventHandler);
			udpClient.reset();	//automatically remove channels
			}
		}
		
		private function clientEventHandler(e:UDPClientEvent){
		
			if(e.type==UDPClientEvent.CONNECTED_TO_SERVER){
			
			udpClient.addChannel(ReliableMode.NO_RELIABLE);
			udpClient.addChannel(ReliableMode.SEMI_RELIABLE,true);
			udpClient.addChannel(ReliableMode.FULL_RELIABLE,true,true);
			this.dispatchEvent(new SimpleEvent(SimpleEvent.CONNECTED_TO_SERVER));
			}
			else if(e.type==UDPClientEvent.CONNECTION_FAILED){
			close();
			this.dispatchEvent(new SimpleEvent(SimpleEvent.CONNECTION_FAILED));
			}
			else if(e.type==UDPClientEvent.SERVER_PONG){
			this.dispatchEvent(new PongEvent(PongEvent.SERVER_PONG,e.udpPeer.lastPing));
			}
			else if(e.type==UDPClientEvent.SERVER_TIMED_OUT){
			close();
			this.dispatchEvent(new SimpleEvent(SimpleEvent.SERVER_TIMED_OUT));
			}
			else if(e.type==UDPClientEvent.SERVER_SENT_DATA){
			this.dispatchEvent(new NetMessageEvent(NetMessageEvent.INCOMING_MESSAGE,NetMessage.unserialize(e.udpDataInfo.data)));
			}
			
			
		}
		private function serverEventHandler(e:UDPServerEvent){
		var client:Client;
			if(e.type==UDPServerEvent.CLIENT_CONNECTED){
			trace(e.udpPeer.address,":",e.udpPeer.port);
			client=new Client(IDGenerator.getNextID(IDGeneratorChannels.PLAYERS),e.udpPeer);	//Create new client
			connectingClients.push(client);
			udpServer.addChannel(ReliableMode.NO_RELIABLE+client.id);							//
			udpServer.addChannel(ReliableMode.SEMI_RELIABLE+client.id,true);					//add private channels to client
			udpServer.addChannel(ReliableMode.FULL_RELIABLE+client.id,true,true);				//
			this.dispatchEvent(new IDRelatedEvent(IDRelatedEvent.NEW_CLIENT_CONNECTING,client.id));
			}
			else if(e.type==UDPServerEvent.CLIENT_PONG){
			client=IterableTools.getElementByProperties(clients,[["udpPeer",e.udpPeer]]);
			if(client)this.dispatchEvent(new PongEvent(PongEvent.CLIENT_PONG,e.udpPeer.lastPing,client.id));
			}
			else if(e.type==UDPServerEvent.CLIENT_TIMED_OUT){
			client=IterableTools.getElementByProperties(clients,[["udpPeer",e.udpPeer]]);
				if(client==null){client=IterableTools.getElementByProperties(connectingClients,[["udpPeer",e.udpPeer]]);
				connectingClients.splice(connectingClients.indexOf(client),1);
				}
				else
				clients.splice(clients.indexOf(client),1);
			this.dispatchEvent(new IDRelatedEvent(IDRelatedEvent.CLIENT_TIMED_OUT,client.id));
			}
			else if(e.type==UDPServerEvent.CLIENT_SENT_DATA){
			client=IterableTools.getElementByProperties(clients,[["udpPeer",e.udpPeer]]);
				if(client==null){
				client=IterableTools.getElementByProperties(connectingClients,[["udpPeer",e.udpPeer]]);
					if(client && e.udpDataInfo.data.type==ClientPlayerInfoMessage.USER_INFOS){
					connectingClients.splice(connectingClients.indexOf(client),1);
					clients.push(client);
					}
					else trace("something weird is happening...");
				}
			this.dispatchEvent(new NetMessageEvent(NetMessageEvent.INCOMING_MESSAGE,NetMessage.unserialize(e.udpDataInfo.data),client.id));
			}
		}
		
	}
}

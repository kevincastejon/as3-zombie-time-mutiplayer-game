package gameGUI {
	import fl.controls.Label;
	import fl.controls.List;
	import fl.controls.TextArea;
	import fl.controls.Button;
	import fl.controls.TextInput;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import piooas3Tools.air.net.udp.UDPServer;
	import piooas3Tools.air.net.udp.UDPClient;
	import piooas3Tools.air.net.udp.UDPServerEvent;
	import piooas3Tools.air.net.udp.UDPClientEvent;
	import flash.events.DatagramSocketDataEvent;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import piooas3Tools.air.net.udp.UDPManager;
	import piooas3Tools.air.net.udp.UDPPeer;
	import piooas3Tools.air.net.udp.UDPManagerEvent;
	import fl.events.ListEvent;
	import flash.events.ErrorEvent;
	import fl.data.DataProvider;
	
	
	public class MainMenu extends MovieClip {
		private var btLANHostRetry:Button;
		private var btOnlineRetry:Button;
		private var lbLANTrouble:Label;
		private var lbOnlineTrouble:Label;
		private var lbRooms:Label;
		private var btnQuit:Button;
		private var btnJoin:Button;
		private var btnHost:Button;
		private var btConnect:Button;
		private var lstRooms:List;
		
		private var menu:Sprite=new Sprite();
		private var rooms:Sprite=new Sprite();
		
		private var holePunchAddress:String="46.105.31.202";
		private var holePunchHostPort:int=9999;
		
		private var clientPort:int=11111;
		
		private var server:UDPServer;
		private var client:UDPClient;
		
		private var onlineRoomID:int;
		private var ownAddress:String;
		private var ownPort:int;
		
		private var broadcastTimer:Timer=new Timer(1000);
		private var reachHolePunchServerTimer:Timer=new Timer(5000,1);
		
		private var localRoomID:Number=Math.random();
		
		public var junctionAddress:String;
		public var junctionPort:int;
		
		public function MainMenu() {
			btLANHostRetry=s_btLANHostRetry;
			btOnlineRetry=s_btOnlineRetry;
			lbLANTrouble=s_lbLANTrouble;
			lbOnlineTrouble=s_lbOnlineTrouble;
			

			btnQuit=s_btnQuit;

			btnJoin=s_btnJoin;
			btnHost=s_btnHost;
			
			lbRooms=s_lbRooms;
			btConnect=s_btConnect;
			lstRooms=s_lstRooms;

			menu.addChild(btnQuit);menu.addChild(btnJoin);menu.addChild(btnHost);
			addChild(menu);
			rooms.addChild(lstRooms);rooms.addChild(btConnect);rooms.addChild(lbRooms);
			addChild(rooms);
			
			
			rooms.visible=false;
			
			reachHolePunchServerTimer.addEventListener(TimerEvent.TIMER, reachHolePunchTimeOut);
			broadcastTimer.addEventListener(TimerEvent.TIMER,broadcast);
			btnHost.addEventListener(MouseEvent.CLICK, menuHandler);
			btnJoin.addEventListener(MouseEvent.CLICK, menuHandler);
			lstRooms.addEventListener(Event.CHANGE, roomSelected);
			btConnect.addEventListener(MouseEvent.CLICK, connectToRoom);
			btOnlineRetry.addEventListener(MouseEvent.CLICK, retryOnline);
			btLANHostRetry.addEventListener(MouseEvent.CLICK, retryLAN);
		}
		
		private function menuHandler(e:Event):void{
			if(e.currentTarget == btnHost){
				menu.visible=false;
				this.dispatchEvent(new Event("host"));
			}
			else if(e.currentTarget == btnJoin){
				menu.visible=false;
				rooms.visible=true;
				this.dispatchEvent(new Event("join"));
			}
		}
		
		public function hostRoom(udpServer:UDPServer):void{
			server=udpServer;
			server.addChannel("junction",true,true,50,7000);
			server.addChannel("chat",true,true,100,7000);
			server.addEventListener(DatagramSocketDataEvent.DATA, rawReceiveFromClientHandler);
			server.addEventListener(ErrorEvent.ERROR, broadcastImpossible);
			server.sendOutOfChannels({type:"createRoom",name:"Room",localRoomID:localRoomID},holePunchAddress,holePunchHostPort);
			trace("SENT CREATE ROOM");
			reachHolePunchServerTimer.start();
			if(UDPManager.getBroadcastAddresses().length>0){
				startBrodcast();
			}
			else{
				lbLANTrouble.visible=btLANHostRetry.visible=true;
			}
		}
		
		public function searchRooms(udpClient:UDPClient):void{
			client=udpClient;
			client.addChannel("junction",true,true,50,7000);
			client.addChannel("chat",true,true,100,7000);
			client.addEventListener(DatagramSocketDataEvent.DATA, rawReceiveFromServerHandler);
			client.addEventListener(UDPManagerEvent.DATA_RECEIVED, classicReceiveFromServerHandler);
			client.sendOutOfChannels({type:"getRooms"},holePunchAddress,holePunchHostPort);
			reachHolePunchServerTimer.start();
		}
		private function rawReceiveFromClientHandler(e:DatagramSocketDataEvent):void{
			var udpData: Object = JSON.parse(e.data.readUTFBytes(e.data.bytesAvailable));
			if(udpData.type=="confirmCreate"){
			onlineRoomID=udpData.roomID;
			ownAddress=udpData.address;
			ownPort=udpData.port;	
			reachHolePunchServerTimer.stop();
			btOnlineRetry.visible=lbOnlineTrouble.visible=false;
			}
			else if(udpData.type=="connectionRequest"){trace("connectionRequest",udpData.address,udpData.port);
				server.sendToClient("junction",{type:"junction"},new UDPPeer(udpData.address,udpData.port));
			}
			trace("receive raw",e.data);
		}
		private function classicReceiveFromServerHandler(e:UDPManagerEvent):void{
			if(e.udpDataInfo.data.type=="junction"){trace("junction");
				this.junctionAddress=e.udpDataInfo.remoteAddress;
				this.junctionPort=e.udpDataInfo.remotePort;
				this.dispatchEvent(new Event("junctionMade"));		
			}
		}
		private function rawReceiveFromServerHandler(e:DatagramSocketDataEvent):void{
			var udpData: Object = JSON.parse(e.data.readUTFBytes(e.data.bytesAvailable));
			if(udpData.type=="roomList"){
				reachHolePunchServerTimer.stop();
				btOnlineRetry.visible=lbOnlineTrouble.visible=false;
				var max:int=udpData.rooms.length;
				lstRooms.removeAll();
				for(var i:int=0;i<max;i++){
					lstRooms.addItem({label:udpData.rooms[i].name+" - "+udpData.rooms[i].address+":"+udpData.rooms[i].port+" - Type: Internet",type:"ONLINE",data:udpData.rooms[i]});
				}
			}
			else if(udpData.type=="broadcast"){
				var existingRoom:Object=roomExists(udpData.localRoomID);
				if(existingRoom==null)
				lstRooms.addItem({label:udpData.name+" - "+e.srcAddress+":"+e.srcPort+" - Type: LAN",type:"LAN",data:{name:udpData.name,address:e.srcAddress,port:e.srcPort}});
				else if(existingRoom.type=="ONLINE"){
				existingRoom.type="BOTH";
				existingRoom.data.address=e.srcAddress;
				existingRoom.data.port=e.srcPort;
				delete existingRoom.id;
				trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>",existingRoom.data.id);
				existingRoom.label=udpData.name+" - "+e.srcAddress+":"+e.srcPort+" - Type: LAN/Internet";
				//rooms.removeChild(lstRooms);
				var dp:DataProvider=lstRooms.dataProvider;
				//lstRooms=new List();
				lstRooms.dataProvider=dp;
				//rooms.addChild(lstRooms);
				//lstRooms.addEventListener(Event.CHANGE, roomSelected);
				}
			}
		}
		private function startBrodcast():void{
		broadcastTimer.reset();
		broadcastTimer.start();
		}
		private function stopBrodcast():void{
		broadcastTimer.stop();
		}
		private function broadcast(e:Event):void{
			var broadcastAddresses:Vector.<String>=UDPManager.getBroadcastAddresses();
			var max:int=broadcastAddresses.length;
			for(var i:int=0;i<max;i++){
			server.sendOutOfChannels({type:"broadcast",name:"Room",localRoomID:localRoomID},broadcastAddresses[i],11111);trace("broadcasting to",broadcastAddresses[i],":",11111);
			}
		}
		private function roomSelected(e:Event):void{
			trace(lstRooms.selectedIndex,lstRooms.selectedItem.data,lstRooms.selectedItem.data.address,lstRooms.selectedItem.data.port);
		}
		private function connectToRoom(e:Event):void{
			if(lstRooms.selectedItem.hasOwnProperty("id")){
			client.sendOutOfChannels({type:"joinRoom",roomID:lstRooms.selectedItem.data.id},holePunchAddress,holePunchHostPort);
			client.sendToNonServerPeer("junction",{type:"junction"},new UDPPeer(lstRooms.selectedItem.data.address,lstRooms.selectedItem.data.port));
			}
			else{
				this.junctionAddress=lstRooms.selectedItem.data.address;
				this.junctionPort=lstRooms.selectedItem.data.port;
				this.dispatchEvent(new Event("junctionMade"));	
			}
		}
		
		private function roomExists(localRoomID:Number):Object{
			var max:int=lstRooms.length;
			for(var i:int=0;i<max;i++){trace(lstRooms.getItemAt(i).data.localRoomID,"==",localRoomID,(lstRooms.getItemAt(i).data.localRoomID==localRoomID));
				if(lstRooms.getItemAt(i).data.localRoomID==localRoomID)
				return(lstRooms.getItemAt(i));
			}
			return(null);
		}
		
		private function reachHolePunchTimeOut(e:Event):void{
			this.dispatchEvent(new Event("noHolePunchServer"));
		}
		public function retryLAN(e:Event):void{
			if(server){
				if(UDPManager.getBroadcastAddresses().length>0){
				lbLANTrouble.visible=btLANHostRetry.visible=false;
				startBrodcast();
				}
			}
		}
		public function retryOnline(e:Event):void{
			btOnlineRetry.visible=lbOnlineTrouble.visible=false;
			
			if(server)			
			server.sendOutOfChannels({type:"createRoom",name:"Room"},holePunchAddress,holePunchHostPort);
			else
			client.sendOutOfChannels({type:"getRooms"},holePunchAddress,holePunchHostPort);
			
			reachHolePunchServerTimer.reset();
			reachHolePunchServerTimer.start();
		}
		private function broadcastImpossible(e:Event):void{
			this.dispatchEvent(new Event("noLANBroadcast"));
		}
	}
	
}

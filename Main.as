package  {
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import piooas3Tools.fl.utils.IterableTools;
	import utils.IDGeneratorChannels;
	import events.SimpleEvent;
	import events.PongEvent;
	import events.IDRelatedEvent;
	import events.NetMessageEvent;
	import events.ChatEvent;
	import events.CharacterEvent;
	import network.ReliableMode;
	import network.netMessages.clientsMessages.*;
	import network.netMessages.serverMessages.*;
	import network.netMessages.NetMessage;
	import network.NetworkManager;
	import gameGUI.ConnectingScreen;
	import gameGUI.ConnectionForm;
	import gameGUI.Lobby;
	import engine.PlayerInfo;
	import engine.server.ServerGameManager;
	import events.ActorStateEvent;
	import engine.client.ClientGameManager;
	import engine.actors.Player;
	import events.StateInputEvent;
	import events.ActionInputEvent;
	import engine.mobs.Mob;
	import engine.actors.ActorType;
	import engine.inputs.ActionInput;
	import engine.inputs.ActionType;
	import flash.utils.ByteArray;
	import flash.events.FullScreenEvent;
	import flash.display.StageScaleMode;
	import flash.events.NativeWindowDisplayStateEvent;
	import flash.display.StageDisplayState;
	import flash.display.NativeWindowDisplayState;
	import flash.media.Sound;
	import flash.net.URLRequest;
	import piooas3Tools.fl.utils.IDGenerator;
	import piooas3Tools.fl.sounds.MixingBoard;
	import piooas3Tools.fl.sounds.Audio;
	import piooas3Tools.fl.sounds.Magneto;
	import flash.filesystem.File;
	import utils.AudioBank;
	import utils.Calculator;
	import piooas3Tools.fl.utils.MathSup;
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	import piooas3Tools.air.nativeOps.ExternalIPFinder;
	import piooas3Tools.air.nativeOps.NetworkInterfaceFilter;
	import piooas3Tools.air.nativeOps.ProcessLauncher;
	import piooas3Tools.air.TraceWindow;
	import flash.sensors.Accelerometer;
	import com.greensock.TweenLite;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import piooas3Tools.air.net.udp.UDPManager;
	import piooas3Tools.air.net.udp.UDPManagerEvent;
	import piooas3Tools.air.net.udp.UDPClient;
	import gameGUI.MainMenu;
	
	public class Main extends MovieClip {
		
		//private var connectionForm:ConnectionForm=new ConnectionForm();
		private var lobby:Lobby=new Lobby();
		private var networkManager:NetworkManager=new NetworkManager();
		private var serverGameManager:ServerGameManager;
		private var clientGameManager:ClientGameManager;
		private var connectingScreen:ConnectingScreen=new ConnectingScreen();
		private var mainMenu:MainMenu=new MainMenu();
				
		private var players:Vector.<Player>=new Vector.<Player>();
		private var id:int;
		private var nickName:String;
		private var color:uint;
		private var isHost:Boolean;
		private var hero:Player;
		
		private var connected:Boolean;
		private var started:Boolean;
		
		private var mainMusicID:int;
		
		public function Main() {
		
		MixingBoard.addTrack("musics");
		MixingBoard.addTrack("fx");
		Magneto.loadAudio(AudioBank.INTRO_MUSIC_URL,AudioBank.INTRO_MUSIC);Magneto.loadAudio(AudioBank.MAP_MUSIC_URL,AudioBank.MAP_MUSIC);
		Magneto.loadAudio(AudioBank.RIFLE01_URL,AudioBank.RIFLE01);
		Magneto.loadAudio(AudioBank.DEAGLE01_URL,AudioBank.DEAGLE01);
		Magneto.loadAudio(AudioBank.GLOCK01_URL,AudioBank.GLOCK01);
		Magneto.loadAudio(AudioBank.FLAME01_URL,AudioBank.FLAME01);
		Magneto.loadAudio(AudioBank.IMPACT_WOOD01_URL,AudioBank.IMPACT_WOOD01);Magneto.loadAudio(AudioBank.IMPACT_BLOOD01_URL,AudioBank.IMPACT_BLOOD01);
		Magneto.loadAudio(AudioBank.ZOMBIE_GRUNT01_URL,AudioBank.ZOMBIE_GRUNT01);Magneto.loadAudio(AudioBank.ZOMBIE_GRUNT04_URL,AudioBank.ZOMBIE_GRUNT04);Magneto.loadAudio(AudioBank.ZOMBIE_GRUNT06_URL,AudioBank.ZOMBIE_GRUNT06);
		Magneto.loadAudio(AudioBank.ZOMBIE_SHORT01_URL,AudioBank.ZOMBIE_SHORT01);Magneto.loadAudio(AudioBank.ZOMBIE_SHORT02_URL,AudioBank.ZOMBIE_SHORT02);Magneto.loadAudio(AudioBank.ZOMBIE_SHORT03_URL,AudioBank.ZOMBIE_SHORT03);
		Magneto.loadAudio(AudioBank.ZOMBIE_YELL01_URL,AudioBank.ZOMBIE_YELL01);Magneto.loadAudio(AudioBank.ZOMBIE_YELL02_URL,AudioBank.ZOMBIE_YELL02);
		
			
		Magneto.playAudio(AudioBank.INTRO_MUSIC,"musics",1,0,true);
			
		IDGenerator.addChannel(IDGeneratorChannels.PLAYERS);	//Initialization of IDGenerator channels
		IDGenerator.addChannel(IDGeneratorChannels.MOBS);		//
		IDGenerator.addChannel(IDGeneratorChannels.INPUTS);		//
		IDGenerator.addChannel(IDGeneratorChannels.NODES);
		stage.stageFocusRect=false;
		showMainMenu();
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
		mainMenu.addEventListener("host",mainMenuHandler);
		mainMenu.addEventListener("join",mainMenuHandler);
		mainMenu.addEventListener("junctionMade",mainMenuHandler);
		mainMenu.addEventListener("noHolePunchServer",mainMenuHandler);
		mainMenu.addEventListener("noLANBroadcast",mainMenuHandler);
		
		}
		private function showMainMenu():void{
		addChild(mainMenu);
		}
		private function mainMenuHandler(e:Event):void{
			if(e.type=="host"){
				mainMenu.hostRoom(networkManager.startServer(11111));
				id=IDGenerator.getNextID(IDGeneratorChannels.PLAYERS);
				nickName="Survivor";
				color=0;
				isHost=true;
				lobby.addEventListener(SimpleEvent.START, lobbyHandler);
				lobby.addEventListener(SimpleEvent.READY, lobbyHandler);
				lobby.addEventListener(SimpleEvent.UNREADY, lobbyHandler);
				lobby.addEventListener(ChatEvent.CHAT, lobbyHandler);
				lobby.addEventListener(CharacterEvent.SELECTED_CHARACTER, lobbyHandler);
				addChild(lobby);
				lobby.setHeroStaticInfos(id,nickName,color,true);
				networkManager.addEventListener(IDRelatedEvent.NEW_CLIENT_CONNECTING, clientConnectionHandler);
				networkManager.addEventListener(IDRelatedEvent.CLIENT_TIMED_OUT, clientConnectionHandler);
				networkManager.addEventListener(PongEvent.CLIENT_PONG, pongHandler);
				networkManager.addEventListener(NetMessageEvent.INCOMING_MESSAGE, netMessageHandler);
				hero=addPlayer(new PlayerInfo(id,nickName,color,null,false,true));
				Calculator.hero=hero;
			}
			else if(e.type=="join"){
				mainMenu.searchRooms(networkManager.startClient(11111));
			}
			else if(e.type=="junctionMade"){
				removeChild(mainMenu);
				networkManager.addEventListener(SimpleEvent.CONNECTION_FAILED, connectionFailHandler);
				networkManager.addEventListener(SimpleEvent.CONNECTED_TO_SERVER, connectionSuccessHandler);
				networkManager.connectClient(mainMenu.junctionAddress,mainMenu.junctionPort);			
				trace("caca");
			}
			else if(e.type=="noHolePunchServer"){
				trace("NO HOLEPUNCH SERVER");
			}
			else if(e.type=="noLANBroadcast"){
				trace("NO LAN BROADCAST");
			}
		}
		private function keyboardHandler(e:KeyboardEvent):void{
			if(e.keyCode==Keyboard.T && e.ctrlKey && TraceWindow.opened){
				TraceWindow.window.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
				TraceWindow.closeWindow();
				}
			else if(e.keyCode==Keyboard.T && e.ctrlKey && !TraceWindow.opened){
				TraceWindow.openWindow();
				
				TraceWindow.window.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyboardHandler);
				}
		}
		//private function connectionFormHandler(e:Event):void{
		//	if(connectionForm.getHost()){
		//	id=IDGenerator.getNextID(IDGeneratorChannels.PLAYERS);
		//	nickName=connectionForm.getNickName();
		//	color=connectionForm.getColor();
		//	isHost=true;
		//	connectionForm.removeEventListener(SimpleEvent.CONNECTION_FORM_COMPLETED, connectionFormHandler);
		//	//connectionForm.reset();
		//	removeChild(connectionForm);
		//	
		//	lobby.addEventListener(SimpleEvent.START, lobbyHandler);
		//	lobby.addEventListener(SimpleEvent.READY, lobbyHandler);
		//	lobby.addEventListener(SimpleEvent.UNREADY, lobbyHandler);
		//	lobby.addEventListener(ChatEvent.CHAT, lobbyHandler);
		//	lobby.addEventListener(CharacterEvent.SELECTED_CHARACTER, lobbyHandler);
		//	addChild(lobby);
		//	lobby.setHeroStaticInfos(id,nickName,color,true,connectionForm.getConnectionAdress()+"  port : "+connectionForm.getPort());
		//	networkManager.addEventListener(IDRelatedEvent.NEW_CLIENT_CONNECTING, clientConnectionHandler);
		//	networkManager.addEventListener(IDRelatedEvent.CLIENT_TIMED_OUT, clientConnectionHandler);
		//	networkManager.addEventListener(PongEvent.CLIENT_PONG, pongHandler);
		//	networkManager.addEventListener(NetMessageEvent.INCOMING_MESSAGE, netMessageHandler);
		//	networkManager.startServer(connectionForm.getPort());
		//	hero=addPlayer(new PlayerInfo(id,nickName,color,null,false,true));
		//	Calculator.hero=hero;
		//	}
		//	else{
		//	networkManager.addEventListener(SimpleEvent.CONNECTION_FAILED, connectionFailHandler);
		//	networkManager.addEventListener(SimpleEvent.CONNECTED_TO_SERVER, connectionSuccessHandler);
		//	networkManager.startClient(0,connectionForm.getIP(),connectionForm.getPort());
		//	}
		//}
		
		private function connectionFailHandler(e:Event):void{
		//connectionForm.displayWrongIPMessage();
		
		}
		
		private function connectionSuccessHandler(e:Event):void{
		nickName="Survivor";
		color=0;
		isHost=false;
		networkManager.removeEventListener(SimpleEvent.CONNECTION_FAILED, connectionFailHandler);
		networkManager.removeEventListener(SimpleEvent.CONNECTED_TO_SERVER, connectionSuccessHandler);
		networkManager.addEventListener(PongEvent.SERVER_PONG,pongHandler);
		networkManager.addEventListener(SimpleEvent.SERVER_TIMED_OUT,serverTimeOutHandler);
		networkManager.addEventListener(NetMessageEvent.INCOMING_MESSAGE,netMessageHandler);
		//connectionForm.removeEventListener(SimpleEvent.CONNECTION_FORM_COMPLETED, connectionFormHandler);
		//connectionForm.reset();
		
		//send user infos (nick, color, etc) to server
		networkManager.sendToServer(new ClientPlayerInfoMessage(ClientPlayerInfoMessage.USER_INFOS,nickName,color),ReliableMode.FULL_RELIABLE);
		
		}
		
		private function pongHandler(e:PongEvent):void{
			if(e.type==PongEvent.CLIENT_PONG){
				if(IterableTools.getElementByProperties(players,[["id",e.id]])){
				networkManager.sendToAllClients(new ServerPlayerPongMessage(ServerPlayerPongMessage.PLAYER_PONG,e.id,e.time),ReliableMode.FULL_RELIABLE,[e.id]);
					if(!started)lobby.setPlayerPing(e.id,e.time);
					else{//send client ping to in-game scoreboard
						}
				}
			}
			else if(e.type==PongEvent.SERVER_PONG){
				if(connected){
					if(!started)lobby.setPlayerPing(0,e.time);
					else{//send server ping to in-game scoreboard
						}
				}
			}
		}
		
		private function clientConnectionHandler(e:IDRelatedEvent):void{
			if(e.type==IDRelatedEvent.NEW_CLIENT_CONNECTING){
				//do nothin for now
			}
			else if(e.type==IDRelatedEvent.CLIENT_TIMED_OUT){
			removePlayer(IterableTools.getElementByProperties(players,[["id",e.id]]));
			networkManager.sendToAllClients(new ServerPlayerMessage(ServerPlayerMessage.PLAYER_LEAVED,e.id),ReliableMode.FULL_RELIABLE);
			}
		}
		
		private function serverTimeOutHandler(e:Event):void{
		
		ProcessLauncher.rebootApp();
		}	
		
		private function netMessageHandler(e:NetMessageEvent):void{
		var player:Player;
		
			if(isHost){
				if(e.netMessage.type==ClientMessage.READY){
					if(!started){
					lobby.setPlayerReady(e.id,true);
					player=IterableTools.getElementByProperties(players,[["id",e.id]]);
					player.isReady=true;
					networkManager.sendToAllClients(new ServerPlayerMessage(ServerPlayerMessage.PLAYER_READY,e.id),ReliableMode.FULL_RELIABLE,[e.id]);
					}
				}
				else if(e.netMessage.type==ClientMessage.UNREADY){
					if(!started){
					lobby.setPlayerReady(e.id,false);
					player=IterableTools.getElementByProperties(players,[["id",e.id]]);
					player.isReady=false;
					networkManager.sendToAllClients(new ServerPlayerMessage(ServerPlayerMessage.PLAYER_UNREADY,e.id),ReliableMode.FULL_RELIABLE,[e.id]);
					}
				}
				else if(e.netMessage.type==ClientMessage.RETRY){
				
				}
				else if(e.netMessage.type==ClientPlayerInfoMessage.USER_INFOS){
				var userInfoMsg:ClientPlayerInfoMessage=e.netMessage as ClientPlayerInfoMessage;
				networkManager.sendToClient(e.id,new ServerPlayerMessage(ServerPlayerMessage.ID_ASSIGNING,e.id),ReliableMode.FULL_RELIABLE);
				networkManager.sendToClient(e.id,new ServerPlayerListInfoMessage(ServerPlayerListInfoMessage.PLAYERS_LIST_INFOS,getPlayerListInfo()),ReliableMode.FULL_RELIABLE);
				networkManager.sendToAllClients(new ServerPlayerInfoMessage(ServerPlayerInfoMessage.NEW_PLAYER_INFOS,e.id,userInfoMsg.nickName,userInfoMsg.color),ReliableMode.FULL_RELIABLE,[e.id]);
				addPlayer(new PlayerInfo(e.id,userInfoMsg.nickName,userInfoMsg.color));
				
				}
				else if(e.netMessage.type==ClientStateInputMessage.INPUTS){
				var inputMsg:ClientStateInputMessage=e.netMessage as ClientStateInputMessage;
				serverGameManager.setPlayerStateInputBuffer(e.id,inputMsg.stateInputs);
				}
				else if(e.netMessage.type==ClientActionInputMessage.ACTION){
				var actionMsg:ClientActionInputMessage=e.netMessage as ClientActionInputMessage;
				serverGameManager.setActorActionInput(ActorType.PLAYER,e.id,actionMsg.actionInput);
				}
				else if(e.netMessage.type==ClientChatMessage.CHAT){
				var chatMsg:ClientChatMessage=e.netMessage as ClientChatMessage;
				chatMsg.chat=chatMsg.chat.replace(new RegExp("juif|youpin|shoah|Israël"),"*judéo-censure*");
					if(!started)lobby.addToChat(chatMsg.chat,e.id);
				networkManager.sendToAllClients(new ServerPlayerChatMessage(ServerPlayerChatMessage.PLAYER_CHAT,e.id,chatMsg.chat),ReliableMode.FULL_RELIABLE);
				}
				else if(e.netMessage.type==ClientCharMessage.SELECTED_CHARACTER){
				var cltCharMsg:ClientCharMessage=e.netMessage as ClientCharMessage;
					if(!started){
					var charChangeValided:Boolean=lobby.setPlayerChar(e.id,cltCharMsg.character);
						if(charChangeValided){
						networkManager.sendToAllClients(new ServerPlayerCharMessage(ServerPlayerCharMessage.PLAYER_SELECTED_CHARACTER,e.id,cltCharMsg.character),ReliableMode.FULL_RELIABLE);
						player=IterableTools.getElementByProperties(players,[["id",e.id]]);
						if(player.character!=cltCharMsg.character)player.setCharacter(cltCharMsg.character);
						else player.setCharacter(null);
						}
					}
				}
			}
			else{
				
				if(e.netMessage.type==ServerMessage.GAME_OVER){
				clientGameManager.setGameOver();	
				}
				else if(e.netMessage.type==ServerMessage.NEXT_WAVE){
				clientGameManager.setNextWave();	
				}
				else if(e.netMessage.type==ServerMessage.START){
				started=true;
				lobby.removeEventListener(SimpleEvent.READY, lobbyHandler);
				lobby.removeEventListener(SimpleEvent.UNREADY, lobbyHandler);
				lobby.removeEventListener(ChatEvent.CHAT, lobbyHandler);
				lobby.removeEventListener(CharacterEvent.SELECTED_CHARACTER, lobbyHandler);
				removeChild(lobby);
				//lobby.reset();
				clientGameManager=new ClientGameManager();
				clientGameManager.addEventListener(StateInputEvent.STATE_INPUT, clientGameManagerHandler);
				clientGameManager.addEventListener(ActionInputEvent.ACTION_INPUT, clientGameManagerHandler);
				addChild(clientGameManager);
				IterableTools.sortOn(players,"id");
				clientGameManager.start(players,hero);
				Magneto.stopAudiosByNameID(AudioBank.INTRO_MUSIC);
				}
				else if(e.netMessage.type==ServerGameStatesMessage.ACTOR_STATES){
				var srvGameStatesMsg:ServerGameStatesMessage = e.netMessage as ServerGameStatesMessage;//trace(srvGameStatesMsg.actorStates);
				clientGameManager.setActorStates(srvGameStatesMsg.actorStates,srvGameStatesMsg.lastInputID);
				}
				/*else if(e.netMessage.type==ServerMobMessage.MOB_SHOOT){
				var srvMobShootMsg:ServerMobMessage = e.netMessage as ServerMobMessage;
				clientGameManager.setActorActionInput(ActorType.MOB,srvMobShootMsg.mobID,new ActionInput(ActionType.SHOOT,1));
				}
				else if(e.netMessage.type==ServerMobMessage.MOB_STOPSHOOT){
				var srvMobStopShootMsg:ServerMobMessage = e.netMessage as ServerMobMessage;
				clientGameManager.setActorActionInput(ActorType.MOB,srvMobStopShootMsg.mobID,new ActionInput(ActionType.SHOOT,0));
				}
				else if(e.netMessage.type==ServerMobMessage.MOB_DIED){
				var srvMobDeadMsg:ServerMobMessage = e.netMessage as ServerMobMessage;
				getMobByID(srvMobDeadMsg.mobID).dead=true;
				}*/
				else if(e.netMessage.type==ServerPlayerCharMessage.PLAYER_SELECTED_CHARACTER){
				var srvPlayerCharMsg:ServerPlayerCharMessage=e.netMessage as ServerPlayerCharMessage; 
				player=IterableTools.getElementByProperties(players,[["id",srvPlayerCharMsg.playerID]]);
				if(player){
					if(!started){
					lobby.setPlayerChar(srvPlayerCharMsg.playerID,srvPlayerCharMsg.character);
					IterableTools.getElementByProperties(players,[["id",e.id]]);
						if(player.character!=srvPlayerCharMsg.character)player.setCharacter(srvPlayerCharMsg.character);
						else player.setCharacter(null);
						
					}
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerPlayerChatMessage.PLAYER_CHAT){
				var srvPlayerChatMsg:ServerPlayerChatMessage=e.netMessage as ServerPlayerChatMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerChatMsg.playerID]])){
					if(!started){
						if(srvPlayerChatMsg.playerID==id)lobby.addToChat(srvPlayerChatMsg.chat,-2);
						else lobby.addToChat(srvPlayerChatMsg.chat,srvPlayerChatMsg.playerID);
					
					}
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				
				}
				else if(e.netMessage.type==ServerPlayerInfoMessage.NEW_PLAYER_INFOS){
				var srvInfMsg:ServerPlayerInfoMessage=e.netMessage as ServerPlayerInfoMessage;
				addPlayer(new PlayerInfo(srvInfMsg.playerID,srvInfMsg.nickName,srvInfMsg.color));
				}
				/*else if(e.netMessage.type==ServerPlayerLifeMessage.PLAYER_LIFE_CHANGED){
				var srvPlayerLifeMsg:ServerPlayerLifeMessage=e.netMessage as ServerPlayerLifeMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerLifeMsg.playerID]])){
					getPlayerByID(srvPlayerLifeMsg.playerID).setLife(srvPlayerLifeMsg.life);
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerPlayerLifeMessage.PLAYER_MAX_LIFE_CHANGED){
				var srvPlayerMaxLifeMsg:ServerPlayerLifeMessage=e.netMessage as ServerPlayerLifeMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerMaxLifeMsg.playerID]])){
					getPlayerByID(srvPlayerMaxLifeMsg.playerID).maxLife=srvPlayerMaxLifeMsg.life;
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerMobLifeMessage.MOB_LIFE_CHANGED){
				var srvMobLifeMsg:ServerMobLifeMessage=e.netMessage as ServerMobLifeMessage;
					if(getMobByID(srvMobLifeMsg.mobID)){
					getMobByID(srvMobLifeMsg.mobID).setLife(srvMobLifeMsg.life);
					}else trace("mob doesnt exist anymore");
				}
				else if(e.netMessage.type==ServerMobLifeMessage.MOB_MAX_LIFE_CHANGED){
				var srvMobMaxLifeMsg:ServerMobLifeMessage=e.netMessage as ServerMobLifeMessage;
					if(getMobByID(srvMobMaxLifeMsg.mobID)){
					getMobByID(srvMobLifeMsg.mobID).maxLife=srvMobMaxLifeMsg.life;
					}else trace("mob doesnt exist anymore");
				}*/
				else if(e.netMessage.type==ServerPlayerListInfoMessage.PLAYERS_LIST_INFOS){
				var listInfoMsg:ServerPlayerListInfoMessage=e.netMessage as ServerPlayerListInfoMessage;
               // lobby.addEventListener(SimpleEvent.START, lobbyHandler);
                lobby.addEventListener(SimpleEvent.READY, lobbyHandler);
                lobby.addEventListener(SimpleEvent.UNREADY, lobbyHandler);
                lobby.addEventListener(ChatEvent.CHAT, lobbyHandler);
                lobby.addEventListener(CharacterEvent.SELECTED_CHARACTER, lobbyHandler);
                addChild(lobby);
				hero=addPlayer(new PlayerInfo(id,nickName,color));
				Calculator.hero=hero;
				lobby.setHeroStaticInfos(hero.id,hero.nickName,hero.color,false);
				var max:int=listInfoMsg.playersListInfos.length;
					for(var i:int=0;i<max;i++){
					addPlayer(listInfoMsg.playersListInfos[i]);
					}
                connected=true;
				}
				else if(e.netMessage.type==ServerPlayerPongMessage.PLAYER_PONG){
				var srvPlayerPongMsg:ServerPlayerPongMessage=e.netMessage as ServerPlayerPongMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerPongMsg.playerID]])){
						if(!started)lobby.setPlayerPing(srvPlayerPongMsg.playerID,srvPlayerPongMsg.time);
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerPlayerMessage.ID_ASSIGNING){
				var idAssignMsg:ServerPlayerMessage=e.netMessage as ServerPlayerMessage;
				id=idAssignMsg.playerID;
				}
				else if(e.netMessage.type==ServerPlayerMessage.PLAYER_DIED){
				var srvPlayerDiedMsg:ServerPlayerMessage=e.netMessage as ServerPlayerMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerDiedMsg.playerID]])){
					getPlayerByID(srvPlayerDiedMsg.playerID).dead=true;
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerPlayerMessage.PLAYER_LEAVED){
				var srvPlayerLeavedMsg:ServerPlayerMessage=e.netMessage as ServerPlayerMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerLeavedMsg.playerID]])){
					removePlayer(IterableTools.getElementByProperties(players,[["id",srvPlayerLeavedMsg.playerID]]) as Player);
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				
				}
				else if(e.netMessage.type==ServerPlayerMessage.PLAYER_READY){
				var srvPlayerReadyMsg:ServerPlayerMessage=e.netMessage as ServerPlayerMessage;
				player=IterableTools.getElementByProperties(players,[["id",srvPlayerReadyMsg.playerID]]);
				if(player){
					if(!started){
					lobby.setPlayerReady(srvPlayerReadyMsg.playerID,true);
					player.isReady=true;
					}
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerPlayerActionInputMessage.PLAYER_ACTION){
				var srvPlayerActionInputMsg:ServerPlayerActionInputMessage=e.netMessage as ServerPlayerActionInputMessage;
					if(IterableTools.getElementByProperties(players,[["id",srvPlayerActionInputMsg.playerID]])){
					clientGameManager.setActorActionInput(ActorType.PLAYER,srvPlayerActionInputMsg.playerID,srvPlayerActionInputMsg.actionInput);
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
				else if(e.netMessage.type==ServerMobActionInputMessage.MOB_ACTION){
				var srvMobActionInputMsg:ServerMobActionInputMessage=e.netMessage as ServerMobActionInputMessage;
					if(getMobByID(srvMobActionInputMsg.mobID)){
					clientGameManager.setActorActionInput(ActorType.MOB,srvMobActionInputMsg.mobID,srvMobActionInputMsg.actionInput);
					}else trace("mob doesnt exist anymore "+e.netMessage.type);
				}				
				else if(e.netMessage.type==ServerPlayerMessage.PLAYER_UNREADY){
				var srvPlayerUnreadyMsg:ServerPlayerMessage=e.netMessage as ServerPlayerMessage;
				player=IterableTools.getElementByProperties(players,[["id",srvPlayerUnreadyMsg.playerID]]);
				if(player){
					if(!started){
					lobby.setPlayerReady(srvPlayerUnreadyMsg.playerID,false);
					player.isReady=false;
					}
					}else trace("player doesnt exist anymore "+e.netMessage.type);
				}
			}
		}
		
		private function lobbyHandler(e:Event):void{
		 
			if(e.type==ChatEvent.CHAT){
			var chatEvt:ChatEvent=e as ChatEvent;
				if(isHost){
				chatEvt.chat=chatEvt.chat.replace(new RegExp("juif|youpin|shoah|Israël"),"**judéo-censure**");
				lobby.addToChat(chatEvt.chat,-2);
				networkManager.sendToAllClients(new ServerPlayerChatMessage(ServerPlayerChatMessage.PLAYER_CHAT,0,chatEvt.chat),ReliableMode.FULL_RELIABLE);
				}
				else{
				networkManager.sendToServer(new ClientChatMessage(ClientChatMessage.CHAT,chatEvt.chat),ReliableMode.FULL_RELIABLE);
				}
			}
			else if(e.type==CharacterEvent.SELECTED_CHARACTER){
			var charEvt:CharacterEvent=e as CharacterEvent;
				if(isHost){
				networkManager.sendToAllClients(new ServerPlayerCharMessage(ServerPlayerCharMessage.PLAYER_SELECTED_CHARACTER,0,charEvt.character),ReliableMode.FULL_RELIABLE);
				if(hero.character!=charEvt.character)hero.setCharacter(charEvt.character);
				else hero.setCharacter(null);
				}
				else{
				networkManager.sendToServer(new ClientCharMessage(ClientCharMessage.SELECTED_CHARACTER,charEvt.character),ReliableMode.FULL_RELIABLE);
				}
			
			}
			else if(e.type==SimpleEvent.READY){
				if(isHost){
				networkManager.sendToAllClients(new ServerPlayerMessage(ServerPlayerMessage.PLAYER_READY,0),ReliableMode.FULL_RELIABLE);
				}
				else{
				networkManager.sendToServer(new ClientMessage(ClientMessage.READY),ReliableMode.FULL_RELIABLE);
				}
			hero.isReady=true;
			}
			else if(e.type==SimpleEvent.UNREADY){
				if(isHost){
				networkManager.sendToAllClients(new ServerPlayerMessage(ServerPlayerMessage.PLAYER_UNREADY,0),ReliableMode.FULL_RELIABLE);
				}
				else{
				networkManager.sendToServer(new ClientMessage(ClientMessage.UNREADY),ReliableMode.FULL_RELIABLE);
				}
			hero.isReady=false;
			}
			else if(e.type==SimpleEvent.START){
			networkManager.sendToAllClients(new ServerMessage(ServerMessage.START),ReliableMode.FULL_RELIABLE);
			started=true;
			lobby.removeEventListener(SimpleEvent.START, lobbyHandler);
			lobby.removeEventListener(SimpleEvent.READY, lobbyHandler);
			lobby.removeEventListener(SimpleEvent.UNREADY, lobbyHandler);
			lobby.removeEventListener(ChatEvent.CHAT, lobbyHandler);
			lobby.removeEventListener(CharacterEvent.SELECTED_CHARACTER, lobbyHandler);
			removeChild(lobby);
			//lobby.reset();
			serverGameManager=new ServerGameManager();
			addChild(serverGameManager);
			serverGameManager.addEventListener(SimpleEvent.GAME_OVER,serverGameManagerHandler);
			serverGameManager.addEventListener(SimpleEvent.NEW_WAVE,serverGameManagerHandler);
			serverGameManager.addEventListener(ActionInputEvent.ACTION_INPUT,serverGameManagerHandler);
			serverGameManager.addEventListener(ActorStateEvent.ACTOR_STATES,serverGameManagerHandler);
			serverGameManager.start(players,hero);
			Magneto.stopAudiosByNameID(AudioBank.INTRO_MUSIC);
			}
			
		}
		private function serverGameManagerHandler(e:Event):void{
			if(e.type==SimpleEvent.GAME_OVER)networkManager.sendToAllClients(new ServerMessage(ServerMessage.GAME_OVER),ReliableMode.FULL_RELIABLE);
			else if(e.type==SimpleEvent.NEW_WAVE)networkManager.sendToAllClients(new ServerMessage(ServerMessage.NEXT_WAVE),ReliableMode.FULL_RELIABLE);
			else if(e.type==ActorStateEvent.ACTOR_STATES){networkManager.sendToClient((e as ActorStateEvent).playerID,new ServerGameStatesMessage(ServerGameStatesMessage.ACTOR_STATES,(e as ActorStateEvent).actorStates,(e as ActorStateEvent).lastInputID),ReliableMode.NO_RELIABLE);}
			else{
			var evt:ActionInputEvent=e as ActionInputEvent;
				if(evt.actorType==ActorType.PLAYER)networkManager.sendToAllClients(new ServerPlayerActionInputMessage(ServerPlayerActionInputMessage.PLAYER_ACTION,evt.id,evt.actionInput),ReliableMode.FULL_RELIABLE);
				else if(evt.actorType==ActorType.MOB)networkManager.sendToAllClients(new ServerMobActionInputMessage(ServerMobActionInputMessage.MOB_ACTION,evt.id,evt.actionInput),ReliableMode.FULL_RELIABLE);
			}


		}
		private function clientGameManagerHandler(e:Event):void{
		if(e.type==StateInputEvent.STATE_INPUT)networkManager.sendToServer(new ClientStateInputMessage(ClientStateInputMessage.INPUTS,(e as StateInputEvent).stateInputs),ReliableMode.NO_RELIABLE);
		else if(e.type==ActionInputEvent.ACTION_INPUT)networkManager.sendToServer(new ClientActionInputMessage(ClientActionInputMessage.ACTION,(e as ActionInputEvent).actionInput),ReliableMode.FULL_RELIABLE);
		}
		private function addPlayer(playerInfo:PlayerInfo):Player{
		var player:Player=new Player(playerInfo.id,playerInfo.nickName,playerInfo.color);
		player.setCharacter(playerInfo.character);
		player.isReady=playerInfo.isReady;
		player.isHost=playerInfo.isHost;
		players.push(player);
			if(!started && playerInfo.id!=id)lobby.addPlayer(playerInfo);
			//else if(started && isHost)serverGameManager.addPlayer(player);
			//else if(started && isHost==false)clientGameManager.addPlayer(player);
		return(player);
		}
		
		private function removePlayer(player:Player):void{
		players.splice(players.indexOf(player),1);
			if(!started)lobby.removePlayer(player.id);
			else if(isHost)serverGameManager.removePlayer(player);
			//else if(isHost==false)clientGameManager.removePlayer(player);
		}
		private function getPlayerByID(id:int):Player
		{
		return(IterableTools.getElementByProperties(players,[["id",id]]));
		}
		private function getMobByID(id:int):Mob
		{
			if(isHost)
			return(serverGameManager.getMobByID(id));
			else
			return(clientGameManager.getMobByID(id));
		}
		private function getPlayerListInfo():Vector.<PlayerInfo>{
		var vec:Vector.<PlayerInfo>=new Vector.<PlayerInfo>();
		var max:int=players.length;
			for(var i:int=0;i<max;i++){
			vec.push(new PlayerInfo(players[i].id,players[i].nickName,players[i].color,players[i].character,players[i].isReady,players[i].isHost));
			}
		return(vec);
		}
	}
	
}

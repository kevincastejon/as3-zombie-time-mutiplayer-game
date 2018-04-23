package gameGUI {	
	import fl.controls.CheckBox;
	import fl.controls.Button;
	import fl.controls.Label;
	import fl.controls.TextArea;
	import fl.controls.TextInput;
	import flash.display.SimpleButton;
	import piooas3Tools.fl.display.FX;
	import flash.display.Sprite;
	import flash.events.Event;
	import engine.PlayerInfo;
	import flash.events.MouseEvent;
	import fl.controls.ScrollPolicy;
	import fl.events.ComponentEvent;
	import events.SimpleEvent;
	import piooas3Tools.fl.utils.Converter;
	import events.ChatEvent;
	import events.CharacterEvent;
	import flash.display.MovieClip;
	import piooas3Tools.fl.display.ItemList;
	import piooas3Tools.fl.utils.IterableTools;
	
	public class Lobby extends Sprite {
		private var lbcharD:Label;
		private var lbcharC:Label;
		private var lbcharB:Label;
		private var lbcharA:Label;
		private var charD:MovieClip;
		private var charC:MovieClip;
		private var charB:MovieClip;
		private var charA:MovieClip;
		private var chbReady:CheckBox;
		private var btnStart:Button;
		private var lbRoomName:Label;
		private var label:Label;
		private var textArea:TextArea;
		private var textInput:TextInput;
		private var btnSend:SimpleButton;
		private var readyMask:MovieClip;
		
		private var playersList:ItemList= new ItemList();
		
		private var textAreaHtmlContent:String="";
		
		private var heroID:int=-1;
		private var heroNickName:String;
		private var heroColor:uint;
		private var heroIsHost:Boolean;
		private var heroCharacter:String;
		
		
				
		public function Lobby() {
			lbcharD=s_lbcharD;
			lbcharC=s_lbcharC;
			lbcharB=s_lbcharB;
			lbcharA=s_lbcharA;
			charD=s_charD;
			charC=s_charC;
			charB=s_charB;
			charA=s_charA;
			chbReady=s_chbReady;
			btnStart=s_btnStart;
			lbRoomName=s_lbRoomName;
			label=s_label;
			textArea=s_textArea;
			textInput=s_textInput;
			btnSend=s_btnSend;
			readyMask=s_readyMask;
		
		
		charA.addEventListener(MouseEvent.CLICK, charBtnHandler);
		charB.addEventListener(MouseEvent.CLICK, charBtnHandler);
		charC.addEventListener(MouseEvent.CLICK, charBtnHandler);
		charD.addEventListener(MouseEvent.CLICK, charBtnHandler);
		charA.addChild(NativeCharLib.getChar("charA"));
		charB.addChild(NativeCharLib.getChar("charB"));
		charC.addChild(NativeCharLib.getChar("charC"));
		charD.addChild(NativeCharLib.getChar("charD"));
		btnStart.addEventListener(MouseEvent.CLICK, startHandler);
		btnSend.addEventListener(MouseEvent.CLICK, sendChatHandler);
		textInput.addEventListener(ComponentEvent.ENTER,sendChatHandler);
		chbReady.addEventListener(Event.CHANGE, checkBoxHandler);
		playersList.x=5;playersList.y=105;
		addChild(playersList);
		readyMask.visible=false;
		}
		
		public function setHeroStaticInfos(id:int,nickName:String,color:uint,isHost:Boolean):void{
		heroID=id;
		heroNickName=nickName;
		heroColor=color;
		heroIsHost=isHost;
		lbRoomName.text=heroNickName;
		FX.tint(lbRoomName,heroColor);
		}
		public function addPlayer(playerInfo:PlayerInfo):void{
		var playerListItem:PlayerListItem=new PlayerListItem(playerInfo.id,playerInfo.nickName,playerInfo.color,playerInfo.isHost);
		playersList.addItem(playerListItem);
		if(playerInfo.isReady)playerListItem.setReady(true);
		if(playerInfo.character)setPlayerChar(playerInfo.id,playerInfo.character);
		btnStart.visible=false;
		}
		public function setPlayerReady(id:int,bool:Boolean):void{
		var playerlistitem:PlayerListItem=playersList.getItemByProperties([["id",id]]) as PlayerListItem;
		playerlistitem.setReady(bool);
		if(isAllReady() && heroIsHost)btnStart.visible=true;
		else btnStart.visible=false;
		}
		public function setPlayerChar(id:int,char:String):Boolean{
		var playerlistitem:PlayerListItem=playersList.getItemByProperties([["id",id]]) as PlayerListItem;
		var alreadyPickedCharPlayerID:int=getPlayerIDByChar(char);
		var retBool:Boolean;
			if(alreadyPickedCharPlayerID==-1 || alreadyPickedCharPlayerID==id){
			retBool=true;
			var color:uint;
			var oldChar:String;
			var nick:String;
				if(id==heroID){nick=heroNickName;color=heroColor;oldChar=heroCharacter;}
				else {nick=playerlistitem.nickName;color=playerlistitem.color;oldChar=playerlistitem.character;}
				
				if(char!=oldChar){
				FX.tint(this[char],color);
				FX.tint(this["lb"+char],color);
				this["lb"+char].text=nick;
				if(heroID!=id)this[char].mouseEnabled=this[char].mouseChildren=false;
				}
				else
				char=null;
					if(oldChar){
					FX.removeTint(this[oldChar]);
					FX.removeTint(this["lb"+oldChar]);
					this["lb"+oldChar].text="Pick";
					if(heroID!=id)this[oldChar].mouseEnabled=this[oldChar].mouseChildren=true;
					}			
			if(heroID!=id)playerlistitem.setCharacter(char);
			else{
			chbReady.visible=Boolean(char!=null);
			heroCharacter=char;
			}
			if(chbReady.visible==false)btnStart.visible=false;
			
			}
		return(retBool);
		}
		public function setPlayerPing(id:int,ping:int):void{
		var playerlistitem:PlayerListItem=playersList.getItemByProperties([["id",id]]) as PlayerListItem;
		playerlistitem.setPing(ping);
		}

		public function removePlayer(id:int):void{
		var playerItem:PlayerListItem=playersList.getItemByProperties([["id",id]]) as PlayerListItem;
		if(playerItem.character)setPlayerChar(id,playerItem.character);
		playersList.removeItem(playerItem);
		if(isAllReady() && heroIsHost)btnStart.visible=true;
		else btnStart.visible=false;
		}
		
		public function addToChat(text:String,peerSenderId:int=-1):void{
			if(peerSenderId>-1){
			var playerlistitem:PlayerListItem=playersList.getItemByProperties([["id",peerSenderId]]) as PlayerListItem;
			textAreaHtmlContent+='<FONT COLOR="'+Converter.HEXColorToCSSColor(playerlistitem.color)+'">'+playerlistitem.nickName+': </FONT>'+text+'\n';
			}
			else if(peerSenderId==-2)
			textAreaHtmlContent+='<FONT COLOR="'+Converter.HEXColorToCSSColor(heroColor)+'">'+heroNickName+': </FONT>'+text+'\n';
			else
			textAreaHtmlContent+=text+"\n";
		textArea.htmlText=textAreaHtmlContent;
		textArea.verticalScrollPosition=textArea.maxVerticalScrollPosition;
		}
		public function reset():void{
		playersList.clear();
		charA.mouseChildren=charA.mouseEnabled=charB.mouseChildren=charB.mouseEnabled=charC.mouseChildren=charC.mouseEnabled=charD.mouseChildren=charD.mouseEnabled=true;
		FX.removeTint(charA);FX.removeTint(charB);FX.removeTint(charC);FX.removeTint(charD);
		FX.removeTint(lbcharA);FX.removeTint(lbcharB);FX.removeTint(lbcharC);FX.removeTint(lbcharD);
		lbcharA.text=lbcharB.text=lbcharC.text=lbcharD.text="Pick";
		heroID=-1;
		heroColor=0;
		heroIsHost=false;
		heroCharacter=heroNickName=null;
		chbReady.selected=false;
		btnStart.visible=false;
		textAreaHtmlContent="";
		textInput.text=textArea.text="";
		readyMask.visible=false;
		}
		private function sendChatHandler(e:Event):void{
		this.dispatchEvent(new ChatEvent(ChatEvent.CHAT, textInput.text));
		textInput.text="";
		}
		
		private function charBtnHandler(e:Event):void{
		var name:String=e.currentTarget.name;
		name=name.substr(2);
		if(heroIsHost)setPlayerChar(heroID,name);
		this.dispatchEvent(new CharacterEvent(CharacterEvent.SELECTED_CHARACTER,name));
		}
		
		private function checkBoxHandler(e:Event):void{
		if(chbReady.selected){
		readyMask.visible=true;
		this.dispatchEvent(new SimpleEvent(SimpleEvent.READY));
		}
		else{
		readyMask.visible=false;
		this.dispatchEvent(new SimpleEvent(SimpleEvent.UNREADY));
		}
		if(isAllReady() && heroIsHost)btnStart.visible=true;
		else btnStart.visible=false;
		}
		private function startHandler(e:Event):void{
		this.dispatchEvent(new SimpleEvent(SimpleEvent.START));
		}
		private function getPlayerIDByChar(char:String):int{
		if(heroCharacter==char)return(heroID);
		var retID:int=-1;
		var max:int=playersList.length;
			for(var i:int=0;i<max;i++){
			var playerItem:PlayerListItem=playersList.getObjectAt(i) as PlayerListItem;
				if(playerItem.character==char){retID=playerItem.id;break;}
			}
		return(retID);
		}
		private function isAllReady():Boolean{
		var bool:Boolean=true;
		var max:int=playersList.length;
			for(var i:int=0;i<max;i++){
			var playerItem:PlayerListItem=playersList.getObjectAt(i) as PlayerListItem;
				if(playerItem.isReady==false){bool=false;break;}
			}
		if(chbReady.selected==false)bool=false;
		return(bool);
		}
		
	}
}

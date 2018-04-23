package gameGUI {
	import fl.controls.Label;
	import flash.geom.ColorTransform;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	
	public class PlayerListItem extends Sprite {
		private var charB:MovieClip;
		private var charC:MovieClip;
		private var charD:MovieClip;
		private var charA:MovieClip;
		private var LBPing:Label;
		private var host:MovieClip;
		private var userIcon:MovieClip;
		private var label:Label;
		private var iconReady:MovieClip;

		
		private var _id:int;
		private var _nickName:String="";
		private var _color:uint;
		private var _isHost:Boolean;
		private var _isReady:Boolean;
		private var _character:String;
		
		public function PlayerListItem(id:int,nickName:String,color:uint,isHost:Boolean,character:String=null,isReady:Boolean=false){
		this._id=id;this._nickName=nickName;this._color=color;this._isHost=isHost;_character=character;_isReady=isReady;
		charB=s_charB;
		charC=s_charC;
		charD=s_charD;
		charA=s_charA;
		LBPing=s_LBPing;
		host=s_host;
		userIcon=s_userIcon;
		label=s_label;
		iconReady=s_iconReady;
		this.addEventListener(Event.RENDER,rendered);
		}
		private function rendered(e:Event):void{
		label.text=nickName;
		var colorTransform:ColorTransform=new ColorTransform();
		colorTransform.color=color;
		userIcon.transform.colorTransform=colorTransform;
		host.visible=isHost;
		iconReady.visible=charA.visible=charB.visible=charC.visible=charD.visible=false;
		setCharacter(character);
		setReady(isReady);
		}
		public function setReady(bool:Boolean):void{
		iconReady.visible=_isReady=bool;
		}
		public function setCharacter(char:String):void{
		this._character=char;
		charA.visible=charB.visible=charC.visible=charD.visible=false;
		if(char!=null)this[char].visible=true;
		}
		public function setPing(ping:int):void{
		LBPing.text=ping+"ms";
		}
		public function get id():int{
		return(_id);
		}
		public function get nickName():String{
		return(_nickName);
		}
		public function get color():uint{
		return(_color);
		}
		public function get isHost():Boolean{
		return(_isHost);
		}
		public function get isReady():Boolean{
		return(_isReady);
		}
		public function get character():String{
		return(_character);
		}
		
	}
	
}

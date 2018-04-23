package engine {
	
	public class PlayerInfo {
	
		public var id:int;
		public var nickName:String;
		public var color:uint;
		public var character:String;
		public var isReady:Boolean;
		public var isHost:Boolean;
		
		public function PlayerInfo(id:int,nickName:String,color:uint,character:String=null,isReady:Boolean=false,isHost:Boolean=false) {
		this.id=id;this.nickName=nickName;this.color=color;this.character=character,this.isReady=isReady;this.isHost=isHost;
		}
		
		public function serialize():Object{
		return({id:id,nickName:nickName,color:color,character:character,isReady:isReady,isHost:isHost});
		}
		
		public static function unserialize(info:Object):PlayerInfo{
		return(new PlayerInfo(info.id,info.nickName,info.color,info.character,info.isReady,info.isHost));
		}

	}
	
}

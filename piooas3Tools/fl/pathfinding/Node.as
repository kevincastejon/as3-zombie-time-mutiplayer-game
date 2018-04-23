package piooas3Tools.fl.pathfinding
{
	import flash.display.Sprite;
	import flash.geom.Point;

	public class Node extends Sprite
	{
		private static var numNode:int;
		
		private var m_id:int;
		private var m_col:int;
		private var m_line:int;
		private var m_g:int;	//cost from start to current
		private var m_h:int;	//cost from current to end as-the-crow-flies
		private var m_f:int;	//h+g
		private var m_walkable:Boolean;
		private var m_parentNode:Node;
		private var neighbours:Array=[];
		
 
		public function Node(posX:Number,posY:Number,col:int=0,line:int=0)
		{
		m_id=numNode;
		numNode++;
		m_col=col;
		m_line=line;
		x=posX;y=posY;
		this.walkable = walkable;
		h = g = 0;
		f=int.MAX_VALUE;
		m_parentNode = this;
		}
		public function reset():void{
		h = g = 0;
		f=int.MAX_VALUE;
		m_parentNode = this;
		}
		public function set parentNode( param_node:Node ):void{ m_parentNode = param_node; }
		public function set walkable( param_walkable:Boolean ):void{ m_walkable = param_walkable; }
		public function set g( param_g:int ):void{ m_g = param_g; }
		public function set f( param_f:int ):void{ m_f = param_f; }
		public function set h( param_h:int ):void{ m_h = param_h; }
		public function set col( param_col:int ):void{ m_col = param_col; }
		public function set line( param_line:int ):void{ m_line = param_line; }
		public function set id( param_id:int ):void{ m_id = param_id; }
		
 
		public function get parentNode():Node{ return m_parentNode; }
		public function get walkable():Boolean{ return m_walkable; }
		public function get g():int{ return m_g; }
		public function get f():int{ return m_f; }
		public function get h():int{ return m_h; }
		public function get col():int{ return m_col; }
		public function get line():int{ return m_line; }
		public function get id():int{ return m_id; }
		public override function toString():String{return("[Node "+id+"]");}
		
	}
}
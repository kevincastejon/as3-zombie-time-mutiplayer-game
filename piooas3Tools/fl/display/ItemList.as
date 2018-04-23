package piooas3Tools.fl.display {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import piooas3Tools.fl.utils.IterableTools;
	
	public class ItemList extends Sprite{

	private var vertical:Boolean;
	private var items:Vector.<DisplayObject>=new Vector.<DisplayObject>();
		
		public function ItemList(vertical:Boolean=true) {
		this.vertical=vertical;
		}
		public function addItem(item:DisplayObject):void{
		addChild(item);trace("addItem",numChildren);
		items.push(item);
		placeObjects();
		}
		public function removeItem(item:DisplayObject):void{trace("removeItem",numChildren);
		removeChild(item);
		items.splice(items.indexOf(item),1);
		placeObjects();
		}
		public function get length():int{
		return(items.length);
		}
		public function getItemByProperties(propsNameValue:Array):DisplayObject{
		return(IterableTools.getElementByProperties(items,propsNameValue));
		}
		public function getObjectAt(index:int):DisplayObject{
		return(items[index]);
		}
		public function clear():void{
		while(length>0)removeChild(items.shift());
		}
		private function placeObjects():void{
		var max:int=items.length;
		for(var i:int=0;i<max;i++)
			{
			if(vertical && i>0)getObjectAt(i).y=getObjectAt(i-1).y+getObjectAt(i-1).height;
			else if(!vertical && i>0)getObjectAt(i).x=getObjectAt(i-1).x+getObjectAt(i-1).width;
			else getObjectAt(0).x=getObjectAt(0).y=0;
			}
		}
		
	}
	
}

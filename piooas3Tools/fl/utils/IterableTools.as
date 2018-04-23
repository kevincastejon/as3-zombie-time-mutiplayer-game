package piooas3Tools.fl.utils {
	
	public class IterableTools {

		public function IterableTools() {
			// constructor code
		}
		
		public static function getElementByProperties(arrayOrVector:Object,propsNameValue:Array){
		if(arrayOrVector.hasOwnProperty("length")){
		var max:int=arrayOrVector.length;
			for(var i:int=0;i<max;i++){
			var bool:Boolean=true;
			var elt:Object=arrayOrVector[i];
			var max2:int=propsNameValue.length;
				for(var j:int=0;j<max2;j++){
				if(elt[propsNameValue[j][0]]!=propsNameValue[j][1])bool=false;
				}
				if(bool)return(elt);
			}
		}
		else throw new Error("first parameter of getElementByProperties must be array or vector (must contains length properties)");
		return(null);
		}
		
		public static function contains(arrayOrVector:Object,element:Object):Boolean{
		if("indexOf" in arrayOrVector){
		return(arrayOrVector.indexOf(element)>-1);
		}
		else throw new Error("first parameter of contains must be array or vector (must contains indexOf method)");
		return false
		}
		
		public static function sortOn(arrayOrVector:Object,propName:String,ascending:Boolean=true):void{
			if(arrayOrVector.hasOwnProperty("length")){
			var MAX:int=arrayOrVector.length;
			var I:int;
				while(I<MAX){
				var obj:Object;
				var tem:int=int.MAX_VALUE;
					for(var i:int=I;i<MAX;i++){
						if(arrayOrVector[i][propName]<tem){
						tem=arrayOrVector[i][propName];
						obj=arrayOrVector[i];
						}
					}
				swap(arrayOrVector,arrayOrVector[I],obj);
				I++;
				}
			if(!ascending)arrayOrVector.reverse();
			}else throw new Error("first parameter of getElementByProperties must be array or vector (must contains length properties)");
		}
		
		public static function swap(arrayOrVector:Object,itemA:Object,itemB:Object):void{
			if("indexOf" in arrayOrVector){
			var indA:int=arrayOrVector.indexOf(itemA);
			var indB:int=arrayOrVector.indexOf(itemB);
			arrayOrVector[indA]=itemB;
			arrayOrVector[indB]=itemA;
			}
			else throw new Error("first parameter of contains must be array or vector (must contains indexOf method)");
		}

	}
	
}

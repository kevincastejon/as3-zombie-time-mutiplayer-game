package piooas3Tools.fl.pathfinding {
	import flash.geom.Point;


	public class AStar {
		public static const NODE_DISTANCE_VALUE: int = 10;

		private static var openList: Array;
		private static var closeList: Array;

		public static function findPath(graphe: Array, startNode: Node, endNode: Node): Array {
			if(startNode==endNode){return([]);}
			// on crée les listes fermées et les listes ouvertes
			openList = new Array();
			closeList = new Array();

			// on crée la variable qui va accueillir le chemin final
			var finalPath: Array = new Array();
			startNode.g=0;
			openList.push(startNode);
				while(openList.length>0){
				openList.sortOn("f");//trace("openlist:",openList);
				var currentNode:Node=openList[0];//trace(">",currentNode);
					if( currentNode == endNode ){
					break;
					}
				addToCloseList(currentNode);
				var neis:Array=getNeighbours(currentNode,graphe);
				var max:int=neis.length;
					for(var i:int=0;i<max;i++){
					var nei:Node=neis[i];//trace("   ",nei);
						if(nei.walkable && !isOnCloseList(nei)){//trace("      ",nei,nei.g,nei.f,nei.h,isOnOpenList(nei),isOnCloseList(nei));
							if(isNeighbourDiagonal(currentNode,nei)){//trace("diago");
								if(nei.col<currentNode.col&&nei.line<currentNode.line&&(!getNodeByCoord(currentNode.col-1,currentNode.line,graphe).walkable||!getNodeByCoord(currentNode.col,currentNode.line-1,graphe).walkable))continue;
								else if(nei.col>currentNode.col&&nei.line<currentNode.line&&(!getNodeByCoord(currentNode.col+1,currentNode.line,graphe).walkable||!getNodeByCoord(currentNode.col,currentNode.line-1,graphe).walkable))continue;
								else if(nei.col>currentNode.col&&nei.line>currentNode.line&&(!getNodeByCoord(currentNode.col+1,currentNode.line,graphe).walkable||!getNodeByCoord(currentNode.col,currentNode.line+1,graphe).walkable))continue;
								else if(nei.col<currentNode.col&&nei.line>currentNode.line&&(!getNodeByCoord(currentNode.col-1,currentNode.line,graphe).walkable||!getNodeByCoord(currentNode.col,currentNode.line+1,graphe).walkable))continue;
							}	
							if(!isOnOpenList(nei)){
							addToOpenList(nei);//trace("pas dans openList");
							nei.g=currentNode.g+Point.distance(new Point(nei.x,nei.y),new Point(currentNode.x,currentNode.y));//trace("      ->g=",nei.g);
							nei.h=Point.distance(new Point(nei.x,nei.y),new Point(endNode.x,endNode.y));//trace("      ->h=",nei.h);
							nei.f=nei.g+nei.h;//trace("      ->f=",nei.f);
							nei.parentNode=currentNode;
							}
							else if(nei.g>currentNode.g+Point.distance(new Point(nei.x,nei.y),new Point(currentNode.x,currentNode.y)))
							{//trace("deja dans openList mais ancien G plus grand");
							nei.g=currentNode.g+Point.distance(new Point(nei.x,nei.y),new Point(currentNode.x,currentNode.y));//trace("      ->g=",nei.g);
							nei.f=nei.g+nei.h;//trace("      ->h=",nei.h);
							nei.parentNode=currentNode;
							}
						
						}
					}
				}
		
			 if( openList.length == 0 ){
			resetNodes(graphe);
			return finalPath;
			 }

		  // Soit on maintenant on construit le chemin à rebours;
		  var lastNode:Node = endNode;
		  while(lastNode != startNode)
		  {
			finalPath.push( lastNode );
			lastNode = lastNode.parentNode;
		  }


		  // on retourne le chemin final
resetNodes(graphe);
		  return finalPath.reverse();
		}

		public static function getNodeByCoord(col:int,line:int, graphe: Array):Node{
		if(col<graphe[0].length && col>=0  && line>=0 && line<graphe.length)return(graphe[line][col]); else return null;
		}
		
		public static function getClosestNodeFromPoint(point:Point, graphe: Array,tileSize:Number,offset:Number=NaN):Node{
		if(!isNaN(offset))point.x-=offset;point.y-=offset;
		var roundedPoint:Point=new Point(Math.round(point.x/tileSize),Math.round(point.y/tileSize));
		return(getNodeByCoord(roundedPoint.x,roundedPoint.y,graphe));
		}
		
		public static function getNodeMapFromIntMap(map:Array,tileSize:Number):Array{
		var realGraphe:Array = new Array();
		var ligne:Array = map[0] as Array;

		var maxcol:int = ligne.length;
		var maxline:int = map.length;

			for ( var i:int = 0; i < maxline; i++ ) 
			{
			var line:Array = new Array();

				for ( var j:int = 0; j < maxcol; j++ )
				{
				var node:Node = new Node(j*tileSize+tileSize/2,i*tileSize+tileSize/2,j,i);
					if ( map[i][j] == 0 )
					{
					node.walkable = false;
					}

				
					
				line.push( node );
				}

			realGraphe.push( line );
			}
		return(realGraphe);
		}

		public static function getNeighbours(node: Node, graphe: Array, onlyWalkables:Boolean=false,deepNess:int=1): Array {
			var neighbours: Array = new Array();
			var tempNei:Node;
			for(var i:int=1;i<deepNess+1;i++){
			tempNei=getNodeByCoord(node.col-i,node.line-i,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col,node.line-i,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col+i,node.line-i,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col+i,node.line,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col+i,node.line+i,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col,node.line+i,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col-i,node.line+i,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			tempNei=getNodeByCoord(node.col-i,node.line,graphe);if(tempNei && (onlyWalkables==false || (onlyWalkables && tempNei.walkable)))neighbours.push(tempNei);
			}
			
			return neighbours;
		}

		private static function resetNodes(map:Array):void{
		var realGraphe:Array = new Array();
		var ligne:Array = map[0] as Array;

		var maxcol:int = ligne.length;
		var maxline:int = map.length;

			for ( var i:int = 0; i < maxline; i++ ) 
				for ( var j:int = 0; j < maxcol; j++ )
				map[i][j].reset();
		}
		
		private static function removeFromCloseList(node: Node): void {
			if(closeList.indexOf(node)>-1)closeList.splice(closeList.indexOf(node),1);
		}

		private static function removeFromOpenList(node: Node): void {
			if(openList.indexOf(node)>-1)openList.splice(openList.indexOf(node),1);
		}


		private static function addToCloseList(node: Node): void {
			removeFromOpenList(node);
			closeList.push(node);
		}


		private static function addToOpenList(node: Node): void {
			removeFromCloseList(node);
			openList.push(node);
		}

		private static function isOnOpenList(node: Node): Boolean {
		return(openList.indexOf(node)>-1);
		}

		private static function isOnCloseList(node: Node): Boolean {
		return(closeList.indexOf(node)>-1);
		}
		
		private static function isNeighbourDiagonal(node:Node,neighbourNode:Node):Boolean{
		return(Boolean(node.line!=neighbourNode.line && node.col!=neighbourNode.col));
		}
	}	
}
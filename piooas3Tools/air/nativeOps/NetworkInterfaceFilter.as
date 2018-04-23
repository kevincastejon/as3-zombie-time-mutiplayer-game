package piooas3Tools.air.nativeOps {
	import flash.net.NetworkInterface;
	import flash.net.NetworkInfo;
	
	public class NetworkInterfaceFilter {

		public static function getFilteredInterfaces():Vector.<NetworkInterface>{
			var interfaces:Vector.<NetworkInterface>=NetworkInfo.networkInfo.findInterfaces();
			var validInterfaces:Vector.<NetworkInterface>=new Vector.<NetworkInterface>;
			var max:int=interfaces.length;
			for(var i:int=0;i<max;i++){
				var ni:NetworkInterface=interfaces[i];
				trace("---"+ni.displayName+"---");
				var max2:int=ni.addresses.length;
					for(var j:int=0;j<max2;j++){trace(ni.addresses[j].ipVersion+" "+ni.addresses[j].address);}
				var bool:Boolean=true;
				if(!ni.active)bool=false;
				//if(ni.addresses.length!=1)bool=false;
				//if(ni.hardwareAddress=="" || ni.hardwareAddress=="00-00-00-00-00-00" || ni.hardwareAddress=="00-00-00-00-00-00-00-E0" || ni.hardwareAddress=="00-00-00-00-00-E0" || ni.hardwareAddress=="00-00-00-00-00-00-E0" || ni.addresses[0].address.match("^(1(0|7|9)2?)\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])\.([01]?[0-9]?[0-9]|2[0-4][0-9]|25[0-5])$")==null)bool=false;
				if(bool)validInterfaces.push(ni);
				
			}
		return(validInterfaces);
		}

	}
	
}

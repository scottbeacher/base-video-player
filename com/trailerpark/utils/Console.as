package com.trailerpark.utils {
	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	public final class Console {
		
		public static const SEPARATOR:String = " ";
		private static var useFirebug:Boolean;
		
		public static function get enabled():Boolean {
			return useFirebug;
		}
		
		public static function set enabled(value:Boolean):void {
			useFirebug = value;
		}
		
		public static function log(...args):void {
			sendToConsole("log", args);
		}		
		public static function info(...args):void {
			sendToConsole("info", args);
		}		
		public static function warn(...args):void {
			sendToConsole("warn", args);
		}
		public static function error(...args):void {
			sendToConsole("error", args);
		}
		public static function fatal(...args):void {
			sendToConsole("fatal", args);
		}
		
		public static function objectOutput(oObj:Object, sPrefix:String = ""):void {
		  
			sPrefix == "" ? sPrefix = "---" : sPrefix += "---";
			  
			for (var i:* in oObj) {
				
				sendToConsole("log", [sPrefix , i + " : " + oObj[i], "  "]);
				if (typeof( oObj[i] ) == "object") objectOutput(oObj[i], sPrefix);       
			}		  
		}
		
		private static function sendToConsole(severity:String, args:Array):void {
			if (useFirebug && ExternalInterface.available && Capabilities.playerType != "StandAlone" && Capabilities.playerType != "External") {
				try {
					ExternalInterface.call("console." + severity, args.join(SEPARATOR));
				}
				catch (error:Error) {
					trace("ExternalInterface failed");
					trace("[" + severity.toUpperCase() + "] " + args.join(SEPARATOR));
				}
			}
			else {
				trace("[" + severity.toUpperCase() + "] " + args.join(SEPARATOR));
			}
		}
	}
}
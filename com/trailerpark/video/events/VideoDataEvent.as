package com.trailerpark.video.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Scott Beacher
	 */
	public class VideoDataEvent extends Event {
		
		public static const CUE_POINT:String = "videoCuePoint";
		public static const IMAGE_DATA:String = "videoImageData";
		public static const META_DATA:String = "videoMetaData";
		public static const TEXT_DATA:String = "videoTextData";
		public static const XMP_DATA:String = "videoXMPData";
		
		protected var _info:Object;
		
		public function VideoDataEvent(type:String, info:Object, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			_info = info;
		} 
		
		public function get info():Object {
			return _info;
		}
		
		public override function clone():Event { 
			return new VideoDataEvent(type, info, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("VideoDataEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
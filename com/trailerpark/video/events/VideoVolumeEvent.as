package com.trailerpark.video.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Scott Beacher
	 */
	public class VideoVolumeEvent extends Event {
		
		public static const CHANGED:String = "volumeChanged";
		
		protected var _volume:Number;
		
		public function VideoVolumeEvent(type:String, volume:Number, bubbles:Boolean= false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			_volume = volume;
		}
		
		public function get volume():Number {
			return _volume;
		}
		
		public override function clone():Event { 
			return new VideoVolumeEvent(type, volume, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("VideoVolumeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}		
	}	
}
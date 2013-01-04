package com.trailerpark.video.events {
	import com.trailerpark.video.data.VideoProgress;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Scott Beacher
	 */
	public class VideoProgressEvent extends Event {
		
		public static const PROGRESS:String = "videoProgress";
		
		protected var _data:VideoProgress;
		
		public function VideoProgressEvent(type:String, data:VideoProgress, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);			
			_data = data;
		} 
		
		public function get data():VideoProgress {
			return _data;
		}
		
		public override function clone():Event { 
			return new VideoProgressEvent(type, data, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("VideoProgressEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
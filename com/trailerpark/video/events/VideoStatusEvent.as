package com.trailerpark.video.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Scott Beacher
	 */
	public class VideoStatusEvent extends Event {
		public static const VIDEO_BUFFER_EMPTY:String = "videoBufferEmpty";
		public static const VIDEO_BUFFER_FULL:String = "videoBufferFull";
		public static const VIDEO_COMPLETE:String = "videoComplete";
		public static const VIDEO_MUTED:String = "videoMuted";
		public static const VIDEO_PAUSED:String = "videoPaused";
		public static const VIDEO_PLAYING:String = "videoPlaying";
		public static const VIDEO_UNMUTED:String = "videoUnmuted";
		public static const VIDEO_RESIZED:String = "videoResized";
		
		public function VideoStatusEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event { 
			return new VideoStatusEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("VideoStatusEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
package com.trailerpark.video.client {
	import com.trailerpark.video.events.VideoDataEvent;
	import flash.events.EventDispatcher;
	
	/**
	 * ...
	 * @author Scott Beacher
	 */
	public class NetStreamClient extends EventDispatcher {
		
		public function NetStreamClient()
		{
			super();
		}
	   	public function onCuePoint(info:Object):void {
			dispatchEvent(new VideoDataEvent(VideoDataEvent.CUE_POINT, info, false, false));			
		}
		public function onImageData(info:Object):void {
			dispatchEvent(new VideoDataEvent(VideoDataEvent.IMAGE_DATA, info, false, false));
		}
	   	public function onMetaData(info:Object):void {
			dispatchEvent(new VideoDataEvent(VideoDataEvent.META_DATA, info, false, false));
    	}
		public function onTextData(info:Object):void {
			dispatchEvent(new VideoDataEvent(VideoDataEvent.TEXT_DATA, info, false, false));
		}
		public function onXMPData(info:Object):void {
			dispatchEvent(new VideoDataEvent(VideoDataEvent.XMP_DATA, info, false, false));
		}
	}
}
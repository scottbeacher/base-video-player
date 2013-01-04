package com.trailerpark.video.data {
	/**
	 * ...
	 * @author Scott Beacher
	 */
	public class VideoProgress {
		
		public var loaded:Number;
		public var played:Number;
		
		public function VideoProgress(loaded:Number, played:Number)
		{
			this.loaded = loaded;
			this.played = played;
		}
	}
}
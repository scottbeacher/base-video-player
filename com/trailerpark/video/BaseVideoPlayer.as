package com.trailerpark.video {
	import com.trailerpark.utils.Console;
	import com.trailerpark.video.client.NetStreamClient;
	import com.trailerpark.video.data.VideoProgress;
	import com.trailerpark.video.events.VideoDataEvent;
	import com.trailerpark.video.events.VideoProgressEvent;
	import com.trailerpark.video.events.VideoStatusEvent;
	import com.trailerpark.video.events.VideoVolumeEvent;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;
	
	/**
	 * Dispatched when an embedded cue point is reached while playing a video.
	 * @eventType com.trailerpark.video.events.VideoDataEvent.CUE_POINT
	 */
	[Event(name = "videoCuePoint", type = "com.trailerpark.video.events.VideoDataEvent")]
	
	/**
	 * Dispatched when the class receives an image embedded in a H.264 file.
	 * @eventType com.trailerpark.video.events.VideoDataEvent.IMAGE_DATA
	 */
	[Event(name = "videoImageData", type = "com.trailerpark.video.events.VideoDataEvent")]	
	
	/**
	 * Dispatched when the class receives meta data while playing a video file.
	 * @eventType com.trailerpark.video.events.VideoDataEvent.META_DATA
	 */
	[Event(name = "videoMetaData", type = "com.trailerpark.video.events.VideoDataEvent")]
	
	/**
	 * Dispatched when the class receives text data embedded in a H.264 file.
	 * @eventType com.trailerpark.video.events.VideoDataEvent.TEXT_DATA
	 */
	[Event(name = "videoTextData", type = "com.trailerpark.video.events.VideoDataEvent")]
	
	/**
	 * Dispatched when the class receives an image embedded in a H.264 file.
	 * @eventType com.trailerpark.video.events.VideoDataEvent.XMP_DATA
	 */
	[Event(name = "videoXMPData", type = "com.trailerpark.video.events.VideoDataEvent")]
	
	/**
	 * Dispatched repeatidly while a stream is playing.
	 * @eventType com.trailerpark.video.events.VideoProgressEvent.PROGRESS
	 */
	[Event(name = "videoProgress", type = "com.trailerpark.video.events.VideoProgressEvent")]
	
	/**
	 * Dispatched when the video buffer is empty.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_BUFFER_EMPTY
	 */
	[Event(name = "videoBufferEmpty", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the video buffer is full.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_BUFFER_FULL
	 */
	[Event(name = "videoBufferFull", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when a stream completes playback.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_COMPLETE
	 */
	[Event(name = "videoComplete", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the video is muted.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_MUTED
	 */
	[Event(name = "videoMuted", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the video is unmuted.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_UNMUTED
	 */
	[Event(name = "videoUnmuted", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the video is paused.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_PAUSED
	 */
	[Event(name = "videoPaused", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the video is playing.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_PLAYING
	 */
	[Event(name = "videoPlaying", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the video is resized.
	 * @eventType com.trailerpark.video.events.VideoStatusEvent.VIDEO_RESIZED
	 */
	[Event(name = "videoResized", type = "com.trailerpark.video.events.VideoStatusEvent")]
	
	/**
	 * Dispatched when the volume is changed
	 * @eventType com.trailerpark.video.events.VideoVolumeEvent.CHANGED
	 */
	[Event(name = "volumeChanged", type = "com.trailerpark.video.events.VideoVolumeEvent")]	
	
	/**
	 * Bare bones video player.
	 * 
	 * @version 0.93 (July 23 2011)
	 * @author Scott Beacher
	 */
	public class BaseVideoPlayer extends Sprite {
		
		/**
		 * Returns if the player will loop upon completion.
		 */
		public var autoLoop:Boolean = false;
		
		/**
		 * Returns if the player seeks back to the start of the video upon completion. This is ignored if autoLoop is set to true.
		 */
		public var autoRewind:Boolean = true;
		
		/**
		 * Returns if events are bubbled.
		 */
		public var bubbleEvents:Boolean = false;
		
		/**
		 * Returns if events can be canceled.
		 */
		public var cancelableEvents:Boolean = false;
		
		protected var client:NetStreamClient;
		protected var connection:NetConnection;
		protected var isStreamBuffering:Boolean = false;
		protected var stream:NetStream;
		protected var streamBufferLength:Number;
		protected var streamDuration:Number;
		protected var streamDurationReceived:Boolean = false;
		protected var timer:Timer;
		protected var videoHeight:int;
		protected var videoWidth:int;
		protected var video:Video;
		
		protected var _isMuted:Boolean = false;
		protected var _isPlaying:Boolean = false;
		protected var _volume:Number;
		
		public function BaseVideoPlayer(videoWidth:int, videoHeight:int, volume:Number = 1, streamBufferLength:Number = 5, timerInterval:int = 100)
		{
			this.videoWidth = videoWidth;
			this.videoHeight = videoHeight;
			this.streamBufferLength = streamBufferLength;
			this._volume = volume;
			
			connection = new NetConnection();
			connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError, false, 0, true);
			connection.addEventListener(IOErrorEvent.IO_ERROR, onIOError, false, 0, true);
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);
			connection.connect(null);
			
			timer = new Timer(timerInterval);
			timer.addEventListener(TimerEvent.TIMER, onTimerInterval, false, 0, true);
		}
		
		/**
		 * Removes all event listeners and releases variables for garabage collection
		 */
		public function destroy():void {
			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, onTimerInterval);
			timer = null;
			
			video.clear();
			video = null;
			
			stream.close();
			stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			stream.client = { };
			stream = null;
			
			client.removeEventListener(VideoDataEvent.META_DATA, onVideoMetaData);
			client.removeEventListener(VideoDataEvent.CUE_POINT, onDispatchDataEvent);
			client.removeEventListener(VideoDataEvent.IMAGE_DATA, onDispatchDataEvent);
			client.removeEventListener(VideoDataEvent.META_DATA, onDispatchDataEvent);
			client.removeEventListener(VideoDataEvent.TEXT_DATA, onDispatchDataEvent);
			client.removeEventListener(VideoDataEvent.XMP_DATA, onDispatchDataEvent);
			client = null;
			
			connection.close();
			connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			connection.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			connection.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			connection = null;			
		}
		
		/**
		 * Indicates if the video is currently playing.
		 */
		public function get isPlaying():Boolean {
			
			return _isPlaying;
		}
		
		/**
		 * Indicates if the video is currently muted.
		 */
		public function get isMuted():Boolean {
			
			return _isMuted;
		}
		
        /**
         * The current volume level of the video. If the video is currently muted this value will be the volume level at the time it was muted. Changing this value will unmute the video if it is currently muted.
         */
        public function get volume():Number {
			
            return _volume;
        }
		
        public function set volume(level:Number):void {
			
            if (level == 0 && !_isMuted) {
                toggleMute();
            }
            else if (_isMuted) {
                _volume = level;
                toggleMute();
            }
            else {
                _volume = level;
                stream.soundTransform = new SoundTransform(_volume);
                dispatchEvent(new VideoVolumeEvent(VideoVolumeEvent.CHANGED, _volume, bubbleEvents, cancelableEvents));
            }
        }
		
		/**
		 * Resizes the video to the specified width and height;
		 * 
		 * @param newWidth Width to resize the video to
		 * @param newHeight Height to resize the video to
		 */
		public function resize(newWidth:int, newHeight:int):void {
			
			this.height = newHeight;
			this.width = newWidth;
			dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_RESIZED, bubbleEvents, cancelableEvents));
		}
		
		/**
		 * Plays the video at the indicated path.
		 * 
		 * @param src The path to a video.
		 */
		public function play(src:String):void {
			
			streamDurationReceived = false;
			stream.close();
			if (!timer.running) {
				timer.start();
			}
			stream.play(src);
		}
		
		/**
		 * Pauses the video.
		 */
		public function pause():void {
			
			stream.pause();
			_isPlaying = false;
			dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_PAUSED, bubbleEvents, cancelableEvents));
		}
		
		/**
		 * Resumes playing a paused video.
		 */
		public function resume():void {
			
			stream.resume();
			_isPlaying = true;
			dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_PLAYING, bubbleEvents, cancelableEvents));
		}
		
        /**
         * Toggle the video between being muted and unmuted.
         */
        public function toggleMute():void {
			
            var newVolume:Number;
            var status:String;
            
            _isMuted = !_isMuted;
            if (_isMuted) {
                newVolume = 0;
                status = VideoStatusEvent.VIDEO_MUTED;
                
            }
            else {
                newVolume = _volume;
                status = VideoStatusEvent.VIDEO_UNMUTED;
            }
            
            stream.soundTransform = new SoundTransform(newVolume);
            dispatchEvent(new VideoStatusEvent(status, bubbleEvents, cancelableEvents));
            dispatchEvent(new VideoVolumeEvent(VideoVolumeEvent.CHANGED, newVolume, bubbleEvents, cancelableEvents));
        }
		
		/**
		 * Toggles the video between being paused and playing.
		 */
		public function togglePause():void {
			
			stream.togglePause();
			_isPlaying = !_isPlaying;
			if (_isPlaying) { 
				dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_PLAYING, bubbleEvents, cancelableEvents));
			}
			else {
				dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_PAUSED, bubbleEvents, cancelableEvents));
			}
		}
		
		/**
		 * Moves the playhead to the percent of the video specified. 
		 * 
		 * @param seconds What percentage of the video in which to seek, value between 0 and 1.
		 */
		public function seekTo(percent:Number):void {
			
			if (percent >= 0 && percent <= 1) {
				seek(percent * streamDuration);
			}
			else {
				Console.error("seekTo out of bounds");
			}
		}
		
		/**
		 * Moves the playhead of the video by the seconds specified relative to where it's currently at. 
		 * 
		 * @param offsetSeconds The offset in the video in which to seek to.
		 */
		public function seekFrom(offsetSeconds:Number):void {
			
			var seekTime:Number = stream.time + offsetSeconds;
			if (seekTime >= 0 && seekTime <= streamDuration) {
				seek(seekTime);
			}
			else {
				Console.error("seekFrom out of bounds");
			}
		}
		
		protected function seek(seekTime:Number):void {
			
			if (streamDurationReceived) {
				if (seekTime >= streamDuration) {
					seekTime = 0;
				}
				stream.seek(seekTime);
			}
			else {
				Console.error("Cannot seek until metaData received");
			}
		}
		
		protected function connectStream():void {
			
			Console.log("connectStream");
			
			stream = new NetStream(connection);
			stream.bufferTime = streamBufferLength;
			stream.soundTransform = new SoundTransform(_volume);
			if (_volume <= 0 && !_isMuted) {
				_volume = 1;
				_isMuted = true;
			}
			stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);
			
			client = new NetStreamClient();
			client.addEventListener(VideoDataEvent.META_DATA, onVideoMetaData, false, 0, true);
			client.addEventListener(VideoDataEvent.CUE_POINT, onDispatchDataEvent, false, 0, true);
			client.addEventListener(VideoDataEvent.IMAGE_DATA, onDispatchDataEvent, false, 0, true);
			client.addEventListener(VideoDataEvent.META_DATA, onDispatchDataEvent, false, 0, true);
			client.addEventListener(VideoDataEvent.TEXT_DATA, onDispatchDataEvent, false, 0, true);
			client.addEventListener(VideoDataEvent.XMP_DATA, onDispatchDataEvent, false, 0, true);
			stream.client = client;
			
			video = new Video(videoWidth, videoHeight);
			video.attachNetStream(stream);
			video.smoothing = true;
			addChild(video);
			
			// bug with multiple instances of video player loaded at different sizes
			this.width = videoWidth;
			this.height = videoHeight;
		}
		
		protected function onNetStatus(eventObject:NetStatusEvent):void {
			
			switch (eventObject.info.code) {
				
				case "NetConnection.Connect.Success":
					connectStream();
					break;
					
				case "NetStream.Play.Stop":
					Console.log("Video completed playing");
					_isPlaying = false;
					if (autoLoop) {
						stream.seek(0);
						dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_COMPLETE, bubbleEvents, cancelableEvents));
						dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_PLAYING, bubbleEvents, cancelableEvents));
					}
					else {
						if (autoRewind) {
							stream.pause();
							stream.seek(0);
						}
						dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_COMPLETE, bubbleEvents, cancelableEvents));
					}
					break;
					
                case "NetStream.Play.StreamNotFound":
					Console.error("Could not find stream");
					break;
					
				case "NetStream.Play.Start":
					Console.log("Video started playing");
					_isPlaying = true;
					dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_PLAYING, bubbleEvents, cancelableEvents));
					break;
					
				case "NetStream.Buffer.Empty":
					if (!isStreamBuffering) {
						dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_BUFFER_EMPTY, bubbleEvents, cancelableEvents));
					}
					isStreamBuffering = false;
					break;
					
				case "NetStream.Buffer.Full":
					dispatchEvent(new VideoStatusEvent(VideoStatusEvent.VIDEO_BUFFER_FULL, bubbleEvents, cancelableEvents));
					isStreamBuffering = false;
					break;
					
				case "NetStream.Buffer.Flush":
					isStreamBuffering = true;
					break;
					
				// ignore these cases
				case "NetConnection.Connect.Closed":
				case "NetStream.Seek.Notify":
					break;
					
				default:
					Console.warn("Unhandled NetStatusEvent: " + eventObject.info.code);
			}
		}
		
		protected function onTimerInterval(eventObject:TimerEvent):void {
			
			dispatchEvent(new VideoProgressEvent(VideoProgressEvent.PROGRESS, new VideoProgress((stream.bytesLoaded / stream.bytesTotal), (stream.time / streamDuration)), bubbleEvents, cancelableEvents));
		}
		
		protected function onVideoMetaData(eventObject:VideoDataEvent):void {
			
			streamDuration = eventObject.info.duration;
			streamDurationReceived = true;
		}
		
		protected function onDispatchDataEvent(eventObject:VideoDataEvent):void {
			
			dispatchEvent(eventObject);
		}
		
		protected function onSecurityError(eventObject:SecurityErrorEvent):void {
			
			Console.error(eventObject);
		}
		
		protected function onIOError(eventObject:IOErrorEvent):void {
			
			Console.error(eventObject);
		}
		
		protected function onAsyncError(eventObject:AsyncErrorEvent):void {
			
			Console.warn(eventObject);
		}
	}
}
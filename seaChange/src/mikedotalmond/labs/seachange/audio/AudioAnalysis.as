/*Copyright (c) 2011 Mike Almond

Permission is hereby granted, free of charge, to any person 
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, 
including without limitation the rights to use, copy, .modify,
merge, publish, distribute, sublicense, and/or sell copies of 
the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.*/

package mikedotalmond.labs.seachange.audio {
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import ru.inspirit.analysis.FFT;
	import ru.inspirit.analysis.FFTSpectrumAnalyzer;

	final public class AudioAnalysis {
		
		private static const BUFFER_SIZE	:uint = 2048;
		private static const BUFFER_SIZE_P1	:uint = BUFFER_SIZE + 1;
		
		private var _audioDriver	:Sound;
		private var _loadedAudio	:Sound;
		
		public var beatDetect		:BeatDetect;
		
		private var _fft			:FFT;
		private var _buffer			:ByteArray;
		private var _fftHelp		:FFTSpectrumAnalyzer;
		private var _invBandCount	:Number;
		public var audioChannel		:SoundChannel;
		
		public var spectrumData		:ByteArray;
		public var bands			:Vector.<Number>;
		
		public var bandCount		:uint;
		public var processed		:Boolean = false;
		public var paused			:Boolean = true;
		
		public function AudioAnalysis() {
			init();
		}
		
		private function init():void {
			_audioDriver = new Sound();
			_audioDriver.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			
			_loadedAudio = new Sound();
			
			beatDetect 		= new BeatDetect();
			
			_fft 			= new FFT();
			_fft.init(BUFFER_SIZE, 1); // mono, 2048 sample window
			
			_fftHelp 		= new FFTSpectrumAnalyzer(_fft, 44100);
			bandCount 		= _fftHelp.initLogarithmicAverages(11, 8);
			_invBandCount	= 1.0 / bandCount;
			
			bands 			= new Vector.<Number>(bandCount, true);
			
			_buffer 		= new ByteArray();
			_buffer.endian 	= Endian.LITTLE_ENDIAN;
		}
		
		public function stop():void {
			if (audioChannel) audioChannel.stop();
			try { _loadedAudio.close(); } catch (err:Error) { };
			_loadedAudio = null;
		}
		
		public function loadMP3(uri:String):void {
			stop();
			_loadedAudio = new Sound();
			_loadedAudio.addEventListener(Event.COMPLETE, onAudioLoad, false, 0, true);
			_loadedAudio.addEventListener(IOErrorEvent.IO_ERROR, onAudioError, false, 0, true);
			_loadedAudio.load(new URLRequest(uri));
		}
		
		private function onAudioError(e:IOErrorEvent):void {
			_loadedAudio.removeEventListener(Event.COMPLETE, onAudioLoad);
			_loadedAudio.removeEventListener(IOErrorEvent.IO_ERROR, onAudioError);
		}
		
		public function loadMP3Bytes(bytes:ByteArray):void {
			stop();
			_loadedAudio = new Sound();
			_loadedAudio.loadCompressedDataFromByteArray(bytes, bytes.length);
			onAudioLoad(null);
		}
		
		public function onAudioLoad(e:Event):void {
			_loadedAudio.removeEventListener(IOErrorEvent.IO_ERROR, onAudioError);
			_loadedAudio.removeEventListener(Event.COMPLETE, onAudioLoad);
			audioChannel = _audioDriver.play();
		}		
		
		private function onSampleData(event:SampleDataEvent):void {
			processed 			= false;
			_buffer.position 	= 0;
			
			var read:uint = paused ? 0 : uint(_loadedAudio.extract(_buffer, BUFFER_SIZE));
			
			while (++read < BUFFER_SIZE_P1) { // not ennough data? fill with... noise
				_buffer.writeFloat(Math.random()*0.025);
				_buffer.writeFloat(Math.random()*0.025);
			}
			
			_buffer.position = 0;
			while (--read) {
				// fill output with extracted data
				event.data.writeFloat(_buffer.readFloat());
				event.data.writeFloat(_buffer.readFloat());
			}
		}
		
		// process the buffer data (fft)
		public function process():Boolean {
			
			if (processed) return true;
			else if (_buffer.length == 0) return (processed = false);
			
			/* Beat detection */
			beatDetect.detect(_buffer);
			
			/* spectrum analysis */
			_buffer.position = 0;			
			_fft.setStereoRAWDataByteArray(_buffer);
			_fft.forwardFFT();
			
			spectrumData 	= _fftHelp.analyzeSpectrum(true); // normalised			
			var n:int 		= bandCount;
			var i:int 		= -1; 
			
			while (++i < n) {
				bands[i] = spectrumData.readFloat();
			}
			
			return (processed = true);
		}
	}
}

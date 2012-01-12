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

package uk.co.mikedotalmond.labs.seachange {
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.MotionBlurFilter3D;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.utils.getTimer;
	
	import org.flintparticles.integration.away3d.v4.A3D4Renderer;
	import uk.co.mikedotalmond.labs.away3d4.filters.NoiseFilter3D;
	import uk.co.mikedotalmond.labs.seachange.audio.AudioAnalysis;
	import uk.co.mikedotalmond.labs.seachange.audio.BeatDetect;
	import uk.co.mikedotalmond.labs.seachange.flint.AudioActivity;
	import uk.co.mikedotalmond.labs.seachange.flint.Sparklets;
	
	final public class Main extends Sprite {
		
		private var _view				:View3D;
		private var _emitterSmall		:Sparklets;
		private var _emitterMedium		:Sparklets;
		private var _emitterLarge		:Sparklets;
		private var _particleRenderer	:A3D4Renderer;
		private var _particleContainer	:ObjectContainer3D;
		private var _moblur				:MotionBlurFilter3D;
		private var _bloom				:BloomFilter3D;
		private var _noise				:NoiseFilter3D;
		private var _bgCol				:uint = 0;
		private var _bgColDest			:uint = 0;
		private var _lastMs				:int = 0;
		
		private var _cX					:Number = 0;
		private var _cXStep				:Number = (0.1 * Math.E) / (Math.E * Math.E * Math.E);
		private var _cY					:Number = 0;
		private var _cYStep				:Number = (0.1 * Math.LN2) / (Math.LN2 * Math.LN2 * Math.LN2);
		private var _cZ					:Number = 0;
		private var _cZStep				:Number = (0.1 * Math.LN10) / (Math.LN10 * Math.LN10 * Math.LN10);
		
		public var audioAnalysis		:AudioAnalysis;
		private var _amplitudeFxScale	:Number;
		
		private var _fr					:FileReference;
		
		public function Main(){
			super();
			if (stage) init(null);
			else addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
		}
		
		private function init(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
			stage.showDefaultContextMenu = false;
			
			initView3D();
			initAudio();
			
			stage.doubleClickEnabled = true;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey, false, 0, true);
			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen, false, 0, true);
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, onClick, false, 0, true);
			addEventListener(Event.ENTER_FRAME, enterFrame, false, 0, true);
			onResize(null);
		}
		
		private function onFullscreen(e:FullScreenEvent):void {
			(e.fullScreen) ? Mouse.hide() : Mouse.show();
		}
		
		private function onKey(e:KeyboardEvent):void {
			const k:String = String.fromCharCode(e.charCode);
			if(k == "l" || e.keyCode == Keyboard.UP) loadAudio();
			else if(k == "f") stage.displayState = StageDisplayState.FULL_SCREEN;			
		}
		
		private function initAudio():void {
			audioAnalysis = AudioActivity.AA = new AudioAnalysis();
			(stage.loaderInfo.loaderURL.indexOf("file://") == -1) 
				?	audioAnalysis.loadMP3("./uploads/2011/10/fp11/seaChange/seaChange.mp3")
				:	audioAnalysis.loadMP3("seaChange.mp3");
			_amplitudeFxScale = 1.14;
		}
		
		
		private function loadAudio():void {
			_fr = new FileReference();
			_fr.addEventListener(Event.CANCEL, onFileSelect, false, 0, true);
			_fr.addEventListener(Event.SELECT, onFileSelect, false, 0, true);
			_fr.browse([new FileFilter("mp3", "*.mp3")]);
		}
		
		private function onFileSelect(e:Event):void {
			_fr.removeEventListener(Event.CANCEL, onFileSelect);
			if (e.type == Event.SELECT) {
				_fr.removeEventListener(Event.SELECT, onFileSelect);
				_fr.addEventListener(Event.COMPLETE, onFileSelect);
				_fr.load();
			} else if (e.type == Event.COMPLETE) {
				_fr.removeEventListener(Event.COMPLETE, onFileSelect);
				_fr.data.position = 0;
				if (_fr.type == ".mp3") {
					audioAnalysis.loadMP3Bytes(_fr.data);
				}
			}
		}
		
		
		private function onResize(e:Event):void {
			const w:uint = 1280;
			const h:uint = 640;
			const w2:uint = stage.displayState == StageDisplayState.FULL_SCREEN ? stage.fullScreenWidth : stage.stageWidth;
			const h2:uint = stage.displayState == StageDisplayState.FULL_SCREEN ? stage.fullScreenHeight : stage.stageHeight;
			_view.width  = w2;// Math.min(w, w2);
			_view.height = int(_view.width * (h / w)); // aspect correct
			_view.y 	 = int(h2 / 2 - _view.height / 2);
		}
		
		private function onClick(e:MouseEvent):void {
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				loadAudio();
			} else {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
		
		private function initView3D():void {
			
			_view = new View3D();
			addChild(_view);
			
			_view.camera.z = -1100;
			_view.camera.x = 0;
			_view.camera.lookAt(new Vector3D());
			
			_moblur = new MotionBlurFilter3D(0.925);
			_bloom 	= new BloomFilter3D(8, 8, 0.010, 2, 2);
			_noise  = new NoiseFilter3D(NoiseFilter3D.TYPE_H, 0.66);
			_view.filters3d = [ _noise, _bloom, _moblur];
			
			//addChild(new AwayStats(_view, true, true));
			
			setupParticles();
		}
		
		private function setupParticles():void {
			
			_particleContainer = new ObjectContainer3D();
			_view.scene.addChild(_particleContainer);
			
			_particleRenderer = new A3D4Renderer(_particleContainer);
			
			_emitterSmall = new Sparklets();
			_emitterSmall.init(Sparklets.SIZE_SMALL);
			_particleRenderer.addEmitter(_emitterSmall);
			
			_emitterMedium = new Sparklets();
			_emitterMedium.init(Sparklets.SIZE_MEDIUM);
			_particleRenderer.addEmitter(_emitterMedium);
			_emitterMedium.addEventListener("poolCreate", onParticlePoolCreated, false, 0, true);
			
			_emitterLarge = new Sparklets();
			_emitterLarge.init(Sparklets.SIZE_LARGE);
			_particleRenderer.addEmitter(_emitterLarge);
			
			_emitterSmall.start();
			_emitterMedium.start();
			_emitterLarge.start();
		}
		
		private function onParticlePoolCreated(e:Event):void {
			_emitterMedium.removeEventListener("poolCreate", onParticlePoolCreated);
			audioAnalysis.paused = false; 
		}
		
		private function enterFrame(e:Event):void {
			
			const clock:int = getTimer();
			var dt:Number = 1 / ((clock - _lastMs));
			_lastMs = clock;
			
			audioAnalysis.process();
			
			const b:BeatDetect = audioAnalysis.beatDetect;
			
			if (b.isOnset){
				
				dt *= 1.5;
				var intensity:uint = b.intensity * 8 * _amplitudeFxScale;
				
				_particleContainer.z += ((intensity * 20) - _particleContainer.z) * 0.04;
				
				if (intensity > 12) {
					_amplitudeFxScale *= 0.95;
					intensity *= _amplitudeFxScale;
				} else {
					_amplitudeFxScale += 0.02;
				}
				
				_bgColDest = (((Math.random() * intensity)) & 0xff) << 16 | (((Math.random() * intensity)) & 0xff) << 8 | (((Math.random() * intensity)) & 0xff);
			} else {
				_particleContainer.z *= 0.9;
				if (_particleContainer.z < 0.01) _particleContainer.z = 0;
			}
			
			
			_cX += _cXStep; _cY += _cYStep; _cZ += _cZStep;
			_view.camera.x += ((b.isOnset ? (_view.camera.x < 0 ? 5.5 : -5.5) : Math.sin(_cX/Math.PI) * 128) - _view.camera.x) * 0.1;
			_view.camera.y = Math.sin(_cZ/Math.PI) * 80;
			_view.camera.lookAt(_emitterMedium.position);
			
			var peak:Number = 0;
			if (audioAnalysis.audioChannel){
				var l:Number = audioAnalysis.audioChannel.leftPeak * _amplitudeFxScale;
				var r:Number = audioAnalysis.audioChannel.rightPeak * _amplitudeFxScale;
				peak = Math.exp(Math.sqrt(l * l + r * r)) / Math.LOG2E;
				
			
				_emitterMedium.sineZone.scaleY += ((l + r + (b.isOnset ? 4 : 0)) - _emitterMedium.sineZone.scaleY) * 0.8; 
				_emitterMedium.sineZone.scaleX += (((2.25 - peak) + (b.isOnset ? 4 : 0)) - _emitterMedium.sineZone.scaleX) * 0.8;
				
				_view.camera.x += (((l - r) * 1024) - _view.camera.x) * 0.006;
				_view.camera.y += (peak * Math.sin(l - r) * 1024 - _view.camera.y) * 0.003;	
				_view.camera.z += ( -1200 + Math.cos(Math.sin(_cZ + (1 / peak))) * (348 * peak * _amplitudeFxScale) - _view.camera.z) * 0.01;
			}
			
			_bloom.exposure += (((peak * 4.5) + b.intensity) - _bloom.exposure) * 0.0125;
			_view.backgroundColor = _bgCol = stepTowardRGB(_bgCol, _bgColDest, 1);
			
			_emitterSmall.update(dt);
			_emitterMedium.update(dt);
			_emitterLarge.update(dt);
			
			_view.render();
		}
		
		private static function stepTowardRGB(current:uint, destination:uint, stepSize:uint):uint {
			if (current == destination) return current;
			
			var r1:uint = (current & 0xff0000) >> 16;
			var g1:uint = (current & 0x00ff00) >> 8;
			var b1:uint = (current & 0xff);
			var dt:int;
			var sign:int;
			
			dt = (((destination & 0xff0000) >> 16) - r1);
			sign = dt < 0 ? -1 : 1;
			if (dt * sign >= stepSize) r1 += (stepSize * sign);
			
			dt = (((destination & 0x00ff00) >> 8) - g1);
			sign = dt < 0 ? -1 : 1;
			if (dt * sign >= stepSize) g1 += (stepSize * sign);
			
			dt = ((destination & 0xff) - b1);
			sign = dt < 0 ? -1 : 1;
			if (dt * sign >= stepSize) b1 += (stepSize * sign);
			
			return r1 << 16 | g1 << 8 | b1;
		}
	}
}
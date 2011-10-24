/*
Copyright (c) 2011 Mike Almond

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
DEALINGS IN THE SOFTWARE.
*/

package uk.co.mikedotalmond.labs.field  {
	
	/**
	 * ...
	 * @author Mike Almond - https://twitter.com/#!/mikedotalmond
	 */
	
	import de.nulldesign.nd2d.display.World2D;
	import flash.Boot;
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import net.hires.debug.Stats;
	
	public final class Main extends World2D {
		
		[Embed(source = "../../../../../VectorField.pbj", mimeType = "application/octet-stream")]
		private static const VectorFieldShader	:Class;
		
		public static const sizeX				:Number = 960;
		public static const sizeY				:Number = 480;
		
		private var _ui							:UI;
		private var _stats						:Stats;
		private var _field						:Vector.<uint>;
		private var _perlinBd					:BitmapData;
		private var _fieldBd					:BitmapData;
		private var _vfRect						:Rectangle;
		private var _vfShader					:Shader;
		private var _vfShaderJob				:ShaderJob;
		
		private var _offsets					:Array/*Point*/ = [new Point()];
		private var _perlinSpeedX				:Number = 0;
		private var _perlinSpeedY				:Number = 0;
		private var _perlinSeed					:uint = 1;
		
		public var world						:FlowWorld;
		
		public function Main():void {
			new Boot(); // <---- Necessary for Nape (or any other haXe library)
			
			enableErrorChecking = false;
            super(Context3DRenderMode.AUTO, 30, new Rectangle(0, 0, sizeX, sizeY));

			// entry point
			stage.quality 	= StageQuality.HIGH;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align 	= StageAlign.TOP_LEFT;
			stage.showDefaultContextMenu = false;
			
			// create world
			world = new FlowWorld();
			setActiveScene(world);
			stage.quality = StageQuality.LOW;
			
			_vfRect   = new Rectangle(0, 0, sizeX, sizeY);
			_perlinBd = new BitmapData(sizeX>>1, sizeY>>1, false, 0);
			_fieldBd  = _perlinBd.clone();
			
			// initialise v field
			const n:int = _perlinBd.width * _perlinBd.height;
			_field 		= new Vector.<uint>(n, true);
			while (--n > -1) { _field[n] = 0x00808000; }
			
			_vfShader = new Shader(new VectorFieldShader());
			_vfShader.data.src.input = _perlinBd;
			
			_ui = new UI(this, 0, sizeY);
			_ui.gravityXSlider.addEventListener(Event.CHANGE, function(e:Event):void { world.space.gravity.x = _ui.gravityXSlider.value; });
			_ui.gravityYSlider.addEventListener(Event.CHANGE, function(e:Event):void { world.space.gravity.y = _ui.gravityYSlider.value; });
			_ui.perlinXSlider.addEventListener(Event.CHANGE, function(e:Event):void { _perlinSpeedX = _ui.perlinXSlider.value; });
			_ui.perlinYSlider.addEventListener(Event.CHANGE, function(e:Event):void { _perlinSpeedY = _ui.perlinYSlider.value; });
			_ui.perlinSeedSlider.addEventListener(Event.CHANGE, function(e:Event):void { _perlinSeed = _ui.perlinSeedSlider.value; });
			_ui.fieldSlider.addEventListener(Event.CHANGE, function(e:Event):void { world.fieldForce = _ui.fieldSlider.value; });
			/*
			_ui.fieldSlider.value 		= world.fieldForce;
			_ui.gravityXSlider.value 	= world.space.gravity.x = 0;// -15;
			_ui.gravityYSlider.value 	= world.space.gravity.y = 0;//-10;
			_ui.perlinXSlider.value 	= _perlinSpeedX = 0.3;
			_ui.perlinYSlider.value 	= _perlinSpeedY = 0.2;
			_ui.fieldSlider.value 		= world.fieldForce = 8;
			_ui.perlinSeedSlider.value 	= _perlinSeed = 1;*/
			
			_stats = new Stats();
			addChild(_stats);
			
			start();
			step(null);	
			
			stage.addEventListener(KeyboardEvent.KEY_UP, onKey, false, 0, true);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onFullscreen);
		}
		
		override protected function context3DCreated(e:Event):void {
            super.context3DCreated(e);
            if(context3D) _stats.driverInfo = context3D.driverInfo;
        }
		
		private function onFullscreen(e:FullScreenEvent):void {
			if (e.fullScreen) {
				_stats.y = _ui.y = 485;
				_ui.x = 86;
			} else {
				_ui.x = _stats.x = _stats.y = 0;
				_ui.y = 480 - _ui.height;
			}
		}
		
        override protected function mainLoop(e:Event):void {
            super.mainLoop(e);
			step(null); // update the field
            if(_stats.parent) _stats.update(statsObject.totalDrawCalls, statsObject.totalTris);
        }
		
		private function onKey(e:KeyboardEvent):void {
			const key:String = String.fromCharCode(e.charCode).toLowerCase();
			if (key == "s" || e.keyCode == Keyboard.LEFT) {
				if (_stats.parent) removeChild(_stats);
				else addChild(_stats);
			} else if (key == "c" || e.keyCode == Keyboard.RIGHT) {
				if (_ui.parent) removeChild(_ui);
				else addChild(_ui);
			} else if (key == "f" || e.keyCode == Keyboard.UP) {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}
		
		private function step(e:Event):void {
			if (e && e.target != this.parent) return;
			
			// update the perlin offsets
			_offsets[0].x -= _perlinSpeedX;
			_offsets[0].y += _perlinSpeedY;
			
			_perlinBd.perlinNoise(96, 96, 1, _perlinSeed, true, false, 1, false, _offsets);
			
			// process pixelbender shader to get the velocity field
			const s:ShaderJob = new ShaderJob(_vfShader, _fieldBd, sizeX, sizeY);
			s.start(true); //synchronusly seems to work better...
			
			// get the field data and give it to the world
			_field 		 	= _fieldBd.getVector(_vfRect);
			_field.fixed 	= true;
			world.field 	= _field;
		}
	}
}
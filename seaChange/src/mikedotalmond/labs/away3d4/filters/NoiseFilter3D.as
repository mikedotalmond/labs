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

package mikedotalmond.labs.away3d4.filters {
	
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.Filter3DBase;
	import away3d.filters.tasks.Filter3DBlurTask;
	import flash.display3D.textures.Texture;
	import mikedotalmond.labs.away3d4.filters.tasks.Filter3DNoiseCompositeTask;
	import mikedotalmond.labs.away3d4.filters.tasks.Filter3DNoiseTask;
	
	public final class NoiseFilter3D extends Filter3DBase {
		
		static public const TYPE_NORMAL:uint = 0;
		static public const TYPE_H:uint = 1;
		static public const TYPE_V:uint = 2;
		
		private var _noiseTask:Filter3DNoiseTask;
		private var _blurTask:Filter3DBlurTask;
		private var _compositeTask:Filter3DNoiseCompositeTask;
		
		public function NoiseFilter3D(type:uint = NoiseFilter3D.TYPE_NORMAL, level:Number = 1, blurX:int = 0, blurY:int = 0){
			super();
			
			_noiseTask = new Filter3DNoiseTask(type);
			_blurTask = blurX > 0 && blurY > 0 ? new Filter3DBlurTask(blurX, blurY) : null;
			_compositeTask = new Filter3DNoiseCompositeTask(level);
			
			addTask(_noiseTask);
			if (_blurTask) addTask(_blurTask);
			addTask(_compositeTask);
		}
		
		public function set compositeLevel(value:Number):void {
			_compositeTask.level = value;
		}
		
		public function get compositeLevel():Number {
			return _compositeTask.level;
		}
		
		override public function setRenderTargets(target:Texture, stage3DProxy:Stage3DProxy):void {
			if (_blurTask){
				_noiseTask.target = _blurTask.getMainInputTexture(stage3DProxy);
				_blurTask.target = _compositeTask.getMainInputTexture(stage3DProxy);
				_compositeTask.overlayTexture = _noiseTask.getMainInputTexture(stage3DProxy);
			} else {
				_noiseTask.target = _compositeTask.getMainInputTexture(stage3DProxy);
				_compositeTask.overlayTexture = _noiseTask.getMainInputTexture(stage3DProxy);
			}
			
			super.setRenderTargets(target, stage3DProxy);
		}
	}
}

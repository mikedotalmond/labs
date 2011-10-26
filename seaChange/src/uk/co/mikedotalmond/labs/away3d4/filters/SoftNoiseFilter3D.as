package uk.co.mikedotalmond.labs.away3d4.filters
{
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.Filter3DBase;
	import away3d.filters.tasks.Filter3DBlurTask;
	import flash.display3D.textures.Texture;
	import uk.co.mikedotalmond.labs.away3d4.filters.tasks.Filter3DNoiseCompositeTask;
	import uk.co.mikedotalmond.labs.away3d4.filters.tasks.Filter3DNoiseTask;

	public final class SoftNoiseFilter3D extends Filter3DBase {
		
		static public const TYPE_NORMAL	:uint = 0;
		static public const TYPE_H		:uint = 1;
		static public const TYPE_V		:uint = 2;
		
		private var _noiseTask 			:Filter3DNoiseTask;
		private var _blurTask 			:Filter3DBlurTask;
		private var _compositeTask 		:Filter3DNoiseCompositeTask;

		public function SoftNoiseFilter3D(type:uint = SoftNoiseFilter3D.TYPE_NORMAL, blurX:int=6, blurY:int=6, level:Number=1) {
			super();
			
			_noiseTask 		= new Filter3DNoiseTask(type);
			_blurTask  		= blurX > 0 && blurY > 0 ? new Filter3DBlurTask(blurX, blurY) : null;
			_compositeTask  = new Filter3DNoiseCompositeTask(level);
			
			addTask(_noiseTask);
			if (_blurTask) addTask(_blurTask);
			addTask(_compositeTask);
		}
		
		public function set compositeLevel(value:Number):void { _compositeTask.level = value; }
		public function get compositeLevel():Number { return _compositeTask.level; }
		
		override public function setRenderTargets(target:Texture, stage3DProxy:Stage3DProxy):void 
		{
			if (_blurTask) {
				_noiseTask.target = _blurTask.getMainInputTexture(stage3DProxy);
				_blurTask.target  = _compositeTask.getMainInputTexture(stage3DProxy);
				_compositeTask.overlayTexture = _noiseTask.getMainInputTexture(stage3DProxy);
			} else {
				_noiseTask.target = _compositeTask.getMainInputTexture(stage3DProxy);
				_compositeTask.overlayTexture = _noiseTask.getMainInputTexture(stage3DProxy);
			}

			super.setRenderTargets(target, stage3DProxy);
		}
	}
}

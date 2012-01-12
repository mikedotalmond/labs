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

package mikedotalmond.labs.away3d4.filters.tasks {
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DTaskBase;
	
	import flash.display3D.Context3DProgramType;
	
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	
	public final class Filter3DNoiseCompositeTask extends Filter3DTaskBase {
		private var _data:Vector.<Number>;
		private var _overlayTexture:TextureBase;
		
		public function Filter3DNoiseCompositeTask(level:Number = 1){
			super();
			_data = Vector.<Number>([level, 0, 0, 0]);
		}
		
		public function get overlayTexture():TextureBase {
			return _overlayTexture;
		}
		
		public function set overlayTexture(value:TextureBase):void {
			_overlayTexture = value;
		}
		
		public function get level():Number {
			return _data[0];
		}
		
		public function set level(value:Number):void {
			_data[0] = value;
		}
		
		override protected function getFragmentCode():String {
			return "tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
					"tex ft1, v0, fs1 <2d,linear,clamp>	\n" +
					"mul ft0, ft0, fc0.x				\n" +
					"add oc, ft0, ft1					\n";
		}
		
		override public function activate(stage3DProxy:Stage3DProxy, camera3D:Camera3D, depthTexture:Texture):void {
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 1);
			stage3DProxy.setTextureAt(1, _overlayTexture);
		}
		
		override public function deactivate(stage3DProxy:Stage3DProxy):void {
			stage3DProxy.setTextureAt(1, null);
		}
	}
}

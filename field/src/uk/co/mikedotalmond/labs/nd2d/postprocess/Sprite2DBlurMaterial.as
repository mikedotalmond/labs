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

package uk.co.mikedotalmond.labs.nd2d.postprocess {
	
	import com.adobe.utils.AGALMiniAssembler;
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.ProgramData;
	import de.nulldesign.nd2d.materials.Sprite2DMaterial;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	/**
	 * Blur Post Process for ND2D based on blur fragment shader (Filter3DBlurTask) in Away3D4 
	 * @see https://github.com/away3d
	 * 
	 * @author Mike Almond - https://twitter.com/#!/mikedotalmond
	 */
	public class Sprite2DBlurMaterial extends Sprite2DMaterial {
		
		private const VERTEX_SHADER:String =
                "m44 op, va0, vc0   \n" + // vertex * clipspace
                "mov v0, va1		\n"; // copy uv
				
				
		private static const MAX_BLUR:int = 6;
		
		private var _blurX	:uint;
		private var _blurY	:uint;
		private var _data	:Vector.<Number>;
		private var _stepX	:Number = 1;
		private var _stepY	:Number = 1;
		private var _numSamples:uint;
		
		public function Sprite2DBlurMaterial(blurX:uint = 3, blurY:uint = 3, width:uint = 960, height:uint = 480) {
			_blurX = blurX; _blurY = blurY;
			_invW = 1.0 / width; _invH = 1.0 / height;
			_data = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, 0]);
			super();
		}
		
		public function setBlur(x:uint=3, y:uint=3, width:uint = 960, height:uint = 480):void {
			_invW = 1.0 / width;
			_invH = 1.0 / height;
			
			_blurX = x;
			if (_blurX > MAX_BLUR) _stepX = _blurX / MAX_BLUR;
			else _stepX = 1;
			
			_blurY = y;
			
			programData = null;
			initProgram(null);
		}
		
		public function get blurX():uint { return _blurX; }
		public function get blurY():uint { return _blurY; }
		
		private function getFragmentCode():String {
			var code:String;
			
			_numSamples = 0;
			
			code = "mov ft0, v0	\n" + "sub ft0.y, v0.y, fc0.y\n";
			
			for (var y:Number = 0; y <= _blurY; y += _stepY){
				if (y > 0)
					code += "sub ft0.x, v0.x, fc0.x\n";
				for (var x:Number = 0; x <= _blurX; x += _stepX){
					++_numSamples;
					if (x == 0 && y == 0)
						code += "tex ft1, ft0, fs0 <2d,nearest,clamp>\n";
					else
						code += "tex ft2, ft0, fs0 <2d,nearest,clamp>\n" + "add ft1, ft1, ft2 \n";
						
					if (x < _blurX)
						code += "add ft0.x, ft0.x, fc1.x	\n";
				}
				if (y < _blurY)
					code += "add ft0.y, ft0.y, fc1.y	\n";
			}
			
			code += "mul ft1, ft1, fc3 \n"; // nd2d colour mult
			code += "add ft1, ft1, fc4 \n"; // nd2d colour offset
					
			code += "mul oc, ft1, fc0.z";
			
			_data[2] = 1 / _numSamples;
			
			return code;
		}
		
		private static var programData:ProgramData;
		private var _invW:Number;
		private var _invH:Number;
		
		
		override protected function prepareForRender(context:Context3D):void {
			super.prepareForRender(context);
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 2);
			
			programConstVector[0] = colorTransform.redMultiplier;
			programConstVector[1] = colorTransform.greenMultiplier;
			programConstVector[2] = colorTransform.blueMultiplier;
			programConstVector[3] = colorTransform.alphaMultiplier;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, programConstVector);
			
			programConstVector[0] = colorTransform.redOffset * ColorOffsetFactor;
			programConstVector[1] = colorTransform.greenOffset * ColorOffsetFactor;
			programConstVector[2] = colorTransform.blueOffset * ColorOffsetFactor;
			programConstVector[3] = colorTransform.alphaOffset * ColorOffsetFactor;
            context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, programConstVector);
		}
		
		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			programData = null;
		}
		
		override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {
			fillBuffer(buffer, v, uv, face, "PB3D_POSITION", 2);
			fillBuffer(buffer, v, uv, face, "PB3D_UV", 2);
		}
		
		override protected function initProgram(context:Context3D):void {
			if (!programData){
				var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);
				
				updateBlurData();
				var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
				colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, getFragmentCode());
				
				var program:Program3D = context.createProgram();
				program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);
				
				programData = new ProgramData(program, 4);
			}
			
			programData = programData;
		}
		
		private function updateBlurData():void {
			
			if (_blurX > MAX_BLUR) _stepX = _blurX / MAX_BLUR;
			else _stepX = 1;
			
			if (_blurY > MAX_BLUR) _stepY = _blurY / MAX_BLUR;
			else _stepY = 1;
			
			_data[0] = _blurX * .5 * _invW;
			_data[1] = _blurY * .5 * _invH;
			_data[4] = _stepX * _invW;
			_data[5] = _stepY * _invH;
		}
	}
}

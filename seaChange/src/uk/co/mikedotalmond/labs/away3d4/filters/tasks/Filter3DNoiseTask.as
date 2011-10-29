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

package uk.co.mikedotalmond.labs.away3d4.filters.tasks {

	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DTaskBase;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import uk.co.mikedotalmond.labs.away3d4.filters.NoiseFilter3D;

	public final class Filter3DNoiseTask extends Filter3DTaskBase {
		
		private var _type:uint;
           
		public function Filter3DNoiseTask(type:uint) {
			_type = type;
			super();
		}
		
		override protected function getFragmentCode() : String {
			return 	_type == NoiseFilter3D.TYPE_NORMAL 	? 	NOISIFY_FRAGMENT_SHADER :
					_type == NoiseFilter3D.TYPE_H 		? 	NOISIFY_H_FRAGMENT_SHADER : 
															NOISIFY_V_FRAGMENT_SHADER;
		}

		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void {
			const w	:Number = 0.0005 + Math.random()*(1/1280);
			const h	:Number = 0.001 + Math.random()*(1/640);
			const cx:Number = w * 0.5;
			const cy:Number = h * 0.5;
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0,Vector.<Number>([cx, cy, w, h]));
		}

		private static const NOISIFY_FRAGMENT_SHADER:String =
                "mov ft0, v0.xy         	                \n" + // get interpolated uv coords
                "sub ft0.zw, ft0.xy, fc0.xy                 \n" + // ft0.xy = outCoord() - fc0.xy
                "div ft0.xy, ft0.xy, fc0.zw                 \n" + // uv = pos.xy - wh
                
				// frc(u*u + v*v) -> ft1.x
				"mul ft1.x, ft0.x, ft0.x                    \n" + //ft1.z = ft0.z * ft0.z;
				"mul ft1.y, ft0.y, ft0.y                    \n" + //ft1.w = ft0.w * ft0.w;
				"add ft1.x, ft1.x, ft1.y                    \n" + // 
				"frc ft1.x, ft1.x							\n" + //
				
				// taking out this chunk gives vertical bands
				"cos ft0.x, ft0.x							\n" +
				"rcp ft0.y, ft1.y							\n" + // 1.0 / ft1.y
				"mul ft0.x, ft0.x, ft1.y					\n" +
				
				// taking out this chunk gives horizontal bands
				"sin ft0.y, ft0.z							\n" +
				"div ft0.z, ft1.y, ft1.x					\n" + 
				"mul ft0.y, ft0.y, ft0.z					\n" +
				
				"mul ft0.xy, ft0.xy, fc0.zw	                \n" + // scale
				"add ft0.xy, ft0.xy, fc0.xy	                \n" + // offset
				
				// sample from fs0 into ft0 at position ft0.xy
				"tex ft0, ft0.xy, fs0 <2d,nearest,repeat,nomip>\n" + // sample texture
				
				// ft0 now contains the sampled texture data
                "mov oc, ft0                                \n";  	// move to output
				
			
			private static const NOISIFY_H_FRAGMENT_SHADER:String =
                "mov ft0, v0.xy         	                \n" + // get interpolated uv coords
                "sub ft0.zw, ft0.xy, fc0.xy                 \n" + // ft0.xy = outCoord() - fc0.xy
                "div ft0.xy, ft0.xy, fc0.zw                 \n" + // uv = pos.xy - wh
                
				// frc(u*u + v*v) -> ft1.x
				"mul ft1.x, ft0.x, ft0.x                    \n" + //ft1.z = ft0.z * ft0.z;
				"mul ft1.y, ft0.y, ft0.y                    \n" + //ft1.w = ft0.w * ft0.w;
				"add ft1.x, ft1.x, ft1.y                    \n" + // 
				"frc ft1.x, ft1.x							\n" + //
				
				// taking out this chunk gives vertical bands
				//"cos ft0.x, ft0.x							\n" +
				//"rcp ft0.y, ft1.y							\n" + // 1.0 / ft1.y
				"mul ft0.x, ft0.x, ft1.y					\n" +
				
				// taking out this chunk (and most of the stuff above) gives horizontal bands
				//"sin ft0.y, ft0.z							\n" +
				//"div ft0.z, ft1.y, ft1.x					\n" + 
				//"mul ft0.y, ft0.y, ft0.z					\n" +
				
				"mul ft0.xy, ft0.xy, fc0.zw	                \n" + // scale
				"add ft0.xy, ft0.xy, fc0.xy	                \n" + // offset
				
				// sample from fs0 into ft0 at position ft0.xy
				"tex ft0, ft0.xy, fs0 <2d,nearest,repeat,nomip>\n" + // sample texture
				
				// ft0 now contains the sampled texture data
                "mov oc, ft0                                \n";  	// move to output
				
				
			
			private static const NOISIFY_V_FRAGMENT_SHADER:String =
			    "mov ft0, v0.xy         	                \n" + // get interpolated uv coords
                "sub ft0.zw, ft0.xy, fc0.xy                 \n" + // ft0.xy = outCoord() - fc0.xy
                "div ft0.xy, ft0.xy, fc0.zw                 \n" + // uv = pos.xy - wh
                
				// frc(u*u + v*v) -> ft1.x
				"mul ft1.x, ft0.x, ft0.x                    \n" + //ft1.z = ft0.z * ft0.z;
				"mul ft1.y, ft0.y, ft0.y                    \n" + //ft1.w = ft0.w * ft0.w;
				"add ft1.x, ft1.x, ft1.y                    \n" + // 
				"frc ft1.x, ft1.x							\n" + //
				
				// taking out this chunk gives vertical bands
				//"cos ft0.x, ft0.x							\n" +
				//"rcp ft0.y, ft1.y							\n" + // 1.0 / ft1.y
				//"mul ft0.x, ft0.x, ft1.y					\n" +
				
				// taking out this chunk gives horizontal bands
				"sin ft0.y, ft0.z							\n" +
				"div ft0.z, ft1.y, ft1.x					\n" + 
				"mul ft0.y, ft0.y, ft0.z					\n" +
				
				"mul ft0.xy, ft0.xy, fc0.zw	                \n" + // scale
				"add ft0.xy, ft0.xy, fc0.xy	                \n" + // offset
				
				// sample from fs0 into ft0 at position ft0.xy
				"tex ft0, ft0.xy, fs0 <2d,nearest,repeat,nomip>\n" + // sample texture
				
				// ft0 now contains the sampled texture data
                "mov oc, ft0                                \n";  	// move to output
		
	}
}

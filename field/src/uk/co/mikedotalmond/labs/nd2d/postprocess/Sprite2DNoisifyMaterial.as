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

package uk.co.mikedotalmond.labs.nd2d.postprocess  {

	/**
	 * Sprite2DNoisifyMaterial
	 * Create a psuedo-random looking noise shader from an input texture.
	 * 
	 * Sampling takes place at (seemingly) random places from the input image,
	 * so the output is noisy but retains the overall colours of the input.
	 * 
	 * @author Mike Almond - https://twitter.com/#!/mikedotalmond
	 * 
	 * 
	 * 
	 * a bit about the fragment shader:
	 * ---------------------------------
	 * The shader takes a few input constants relating to input width/height and an xy offset. 
	 * A single constants register is set, modified by a random jitter, each frame.
	 * Internally, the shader uses 2 temporary registers (float4) for its processing.
	 * 
	 * The ND2D colour multiplier+offset parts of the shader are retained so you can still tint and set a ColourTransform on the material
	 * 
	 * It will depending on what you want to use it for, I'd suggest passing this through a blur afterwards. On the GPU, of course ;)
	 * @see Sprite2DBlurMaterial for just that occasion.
	 * 
	 * Shader based on some of the PixelBender2D code / ideas by Nicolas Barradeau
	 * - http://en.nicoptere.net/?p=302
	 * - https://twitter.com/#!/nicoptere
	 */
	
	 
	import com.adobe.utils.AGALMiniAssembler;
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.ProgramData;
	import de.nulldesign.nd2d.materials.Sprite2DMaterial;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
    public class Sprite2DNoisifyMaterial extends Sprite2DMaterial {

        private const VERTEX_SHADER:String =
                "m44 op, va0, vc0   \n" + // vertex * clipspace
                "mov v0, va1		\n"; // copy uv
		
		
		private const FRAGMENT_SHADER:String =
                "mov ft0, v0.xy         	                \n" + // get interpolated uv coords
                "sub ft0.zw, ft0.xy, fc2.xy                 \n" + // ft0.xy = outCoord() - fc2.xy
                "div ft0.xy, ft0.xy, fc2.zw                 \n" + // uv = pos.xy - wh
                
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
				
				"mul ft0.xy, ft0.xy, fc2.zw	                \n" + // scale
				"add ft0.xy, ft0.xy, fc2.xy	                \n" + // offset
				
				// sample from fs0 into ft0 at position ft0.xy
				"tex ft0, ft0.xy, fs0 <2d,nearest,repeat,nomip>\n" + // sample texture
				
				// ft0 now contains the sampled texture data
				"mul ft0, ft0, fc0                          \n" + 	// mult with colorMultiplier (nd2d)
                "add ft0, ft0, fc1                          \n" + 	// add colorOffset (nd2d)
                "mov oc, ft0                                \n";  	// move to output
		
				
        private static var NoisifyProgramData:ProgramData;
		
        override protected function prepareForRender(context:Context3D):void {
            super.prepareForRender(context);
			
			programConstVector[2] = 0.005 + Math.random() * 0.01; //w
			programConstVector[3] = 0.001 + Math.random() * 0.005; //h
			programConstVector[0] = programConstVector[2] * 0.5; //x (w/2)
			programConstVector[1] = programConstVector[3] * 0.5; //y (h/2)
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, programConstVector);
        }
		
        override public function handleDeviceLoss():void {
            super.handleDeviceLoss();
            NoisifyProgramData = null;
        }

        override protected function addVertex(context:Context3D, buffer:Vector.<Number>, v:Vertex, uv:UV, face:Face):void {
            fillBuffer(buffer, v, uv, face, "PB3D_POSITION", 2);
            fillBuffer(buffer, v, uv, face, "PB3D_UV", 2);
        }

        override protected function initProgram(context:Context3D):void {
            if(!NoisifyProgramData) {
                var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, VERTEX_SHADER);

                var colorFragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
                colorFragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, FRAGMENT_SHADER);

                var program:Program3D = context.createProgram();
                program.upload(vertexShaderAssembler.agalcode, colorFragmentShaderAssembler.agalcode);

                NoisifyProgramData = new ProgramData(program, 4);
				
				context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([0.01, 0.005, 0.005, 0.0025]));
            }

            programData = NoisifyProgramData;
        }
    }
}

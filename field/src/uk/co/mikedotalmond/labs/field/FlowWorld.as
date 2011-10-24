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

package uk.co.mikedotalmond.labs.field {

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.display.TextureRenderer;
	import de.nulldesign.nd2d.events.TextureEvent;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import flash.display.BitmapData;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.shape.Circle;
	import nape.space.Space;
	import uk.co.mikedotalmond.labs.nd2d.postprocess.Sprite2DBlurMaterial;
	import uk.co.mikedotalmond.labs.nd2d.postprocess.Sprite2DNoisifyMaterialH;
	import uk.co.mikedotalmond.labs.nd2d.postprocess.Sprite2DBlurMaterial;
	import flash.display.BitmapData;
	
	/**
	 * FlowWorld - The ND2D scene we'll be rendering in, and the Nape simulation space
	 * 
	 * @author Mike Almond - https://twitter.com/#!/mikedotalmond
	 */
    public class FlowWorld extends Scene2D {

        private var _sprites				:Vector.<Sprite2D>;
        private var spriteCloud				:Node2D;
		
        private var numSprites				:uint = 1000;
		
		public var field					:Vector.<uint>;
		private var _bodies					:Vector.<Body>;
		private var _fieldForce				:Number = 0;
		private var _space					:Space;
		
		private var sceneTextureRenderer	:TextureRenderer;
		private var noisifyTextureRenderer	:TextureRenderer;
		private var noisifyPostProcses		:Sprite2D;
		private var blurPostProcess			:Sprite2D;
		
		private var _v2Zero					:Vec2;
		private var _v2Field				:Vec2;
		
        public function FlowWorld() {
			
			// nape setup
			_space 		= new Space(new Vec2(0, 0));
			_bodies  	= new Vector.<Body>();
            _sprites 	= new Vector.<Sprite2D>();
			_v2Zero 	= new Vec2();
			_v2Field 	= new Vec2();
			createBodies();
			
            // particle texture
			var tex	:BitmapData = new BitmapData(16, 16, true, 0x00000000);
			var shp	:flash.display.Shape = new flash.display.Shape();
			shp.graphics.beginFill(0x333333,1);
			shp.graphics.drawCircle(8, 8, 4.5);
			shp.graphics.endFill();
			
			tex.draw(shp);
			tex.applyFilter(tex, tex.rect, new Point(), new GlowFilter(0xffffff, 1, 8, 8, 4, 3, false, true));
			//*/
            spriteCloud = new Sprite2DCloud(numSprites, tex);
			
			addSprites();
            addChild(spriteCloud);
			
			// render scene to texture for post process
            sceneTextureRenderer = new TextureRenderer(spriteCloud, Main.sizeX, Main.sizeY, 0, 0.0);
            sceneTextureRenderer.addEventListener(TextureEvent.READY, sceneTextureCreated);
            addChild(sceneTextureRenderer);
        }
		
		private function sceneTextureCreated(e:TextureEvent):void {
			if(noisifyPostProcses) {
                removeChild(noisifyPostProcses);
                noisifyPostProcses.dispose();
                noisifyPostProcses = null;
            }
			
            noisifyPostProcses = new Sprite2D(sceneTextureRenderer.texture);
            //noisifyPostProcses.setMaterial(new Sprite2DNoisifyMaterialV());
            noisifyPostProcses.setMaterial(new Sprite2DNoisifyMaterialH());
            //noisifyPostProcses.setMaterial(new Sprite2DNoisifyMaterial());
			noisifyPostProcses.x = noisifyPostProcses.width * 0.5;
            noisifyPostProcses.y = noisifyPostProcses.height * 0.5;
            addChild(noisifyPostProcses);
			
			noisifyPostProcses.alpha = 0.2;
			
			// render noise to texture for further post process
			noisifyTextureRenderer = new TextureRenderer(noisifyPostProcses, Main.sizeX, Main.sizeY, 0, 0);
            noisifyTextureRenderer.addEventListener(TextureEvent.READY, noiseTextureCreated);
            addChild(noisifyTextureRenderer);
        }
		
		private function noiseTextureCreated(e:TextureEvent):void {
			if(blurPostProcess) {
                removeChild(blurPostProcess);
                blurPostProcess.dispose();
                blurPostProcess = null;
            }
			// blur post-process
			blurPostProcess = new Sprite2D(noisifyTextureRenderer.texture);
            blurPostProcess.colorTransform = new ColorTransform(8, 8, 8);
			blurPostProcess.setMaterial(new Sprite2DBlurMaterial(6, 6, 960 / (2 * Math.PI), 480 / (2 * Math.PI)));
			//blurPostProcess.setMaterial(new Sprite2DBlurMaterial(6, 6, 960, 480 ));
			blurPostProcess.blendMode = BlendModePresets.SCREEN;			
			blurPostProcess.x = blurPostProcess.width * 0.5;
            blurPostProcess.y = blurPostProcess.height * 0.5;
            addChild(blurPostProcess);
		}
		
		private function createBodies():void {
			/**
			 * Create nape world bodies here.
			*/
			var r:Number  = 6;
			var n:int = numSprites;
			var body:Body;
			while (--n > -1) {
				body = new Body();
				body.position.setxy(50 + int(Math.random() * (Main.sizeX - 100)), 50 + int(Math.random() * (Main.sizeY - 100)));
				body.space 			= _space;
				body.shapes.add(new Circle(r));
				_bodies.push(body);
			}
			_bodies.fixed = true;
		}

        private function addSprites():void {
			// create all the sprites, add them to the cloud, and push them onto _sprites
            var s:Sprite2D;
            var i:int = numSprites + 1;
			while (--i) _sprites.push( spriteCloud.addChild(new Sprite2D()) as Sprite2D);
			
			_sprites.fixed = true;
			spriteCloud.blendMode = BlendModePresets.ADD;
        }

        override protected function step(elapsed:Number):void {
			// for each body...
				// wrap coordinates if off-screen
				// apply linear damping
				// apply perlin velocity field
				// update particle (Sprite2D) position and tint based on x/y velocity
			// step the physics simulation
			
			var i		:int = _bodies.length;
			var body	:Body;
            var s		:Sprite2D;
			
			const sx	:Number = Main.sizeX;
			const sy	:Number = Main.sizeY
			const force	:Number = _fieldForce * 2048;
			
			var px		:Number;
			var py		:Number;
			
			while (--i > -1) {
				body 	= _bodies[i];
				px 		= body.position.x;
				py 		= body.position.y;
				
				if (px < 0 || px > sx) {
					if (px <= 0) px += sx; else px -= sx;
					body.position.setxy(px, py); // update position
				}
				
				if( py < 0 || py > sy) {
					if (py <= 0) py += sy; else py -= sy;
					body.position.setxy(px, py); // update position
				}
				
				body.velocity.muleq(0.98); // lin damp
				
				// apply velocity field force
				// fx,fy stored in G+B channels of the field
				const c		:int = ( field[int(int(px >> 1) + int(py >> 1) * (sx >> 1))] & 0x0000FFFF);
				body.applyRelativeForce(_v2Field.setxy(
												(((c >> 8)   / 0xFF) - 0.5) * force,
												(((c & 0xFF) / 0xFF) - 0.5) * force
											),
										_v2Zero);
				
				// set sprite position
				s 	= _sprites[i];
				s.x = px; 
				s.y = py;
				
				// tint  sprite based on velocity
				const absx	:Number = Math.sqrt(body.velocity.x < 0 ? -body.velocity.x : body.velocity.x)*10;// * 0.1;
				const absy	:Number = Math.sqrt(body.velocity.y < 0 ? -body.velocity.y : body.velocity.y)*10;// * 0.1;
				s.tint = (((absx > 0xff ? 0xff : absx ) )  | ((absy > 0xff ? 0xff : absy) << 16) );
			}
			
			//step through the simulation
			_space.step(0.02, 10, 10); // 1/50=0.02
        }
		
		public function get fieldForce():Number { return _fieldForce; }
		public function set fieldForce(value:Number):void { _fieldForce = value; }
		
		public function get space():Space { return _space; }
    }
}
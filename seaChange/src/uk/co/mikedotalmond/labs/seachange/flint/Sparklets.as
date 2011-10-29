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

package uk.co.mikedotalmond.labs.seachange.flint {
	
	import away3d.entities.Sprite3D;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import org.flintparticles.common.actions.Age;
	import org.flintparticles.common.actions.Fade;
	import org.flintparticles.common.actions.ScaleImage;
	import org.flintparticles.common.actions.TargetColor;
	import org.flintparticles.common.activities.UpdateOnFrame;
	import org.flintparticles.common.counters.Random;
	import org.flintparticles.common.counters.Steady;
	import org.flintparticles.common.easing.Quadratic;
	import org.flintparticles.common.initializers.ColorsInit;
	import org.flintparticles.common.initializers.ImageInitializerBase;
	import org.flintparticles.common.initializers.Lifetime;
	import org.flintparticles.common.initializers.ScaleImagesInit;
	import org.flintparticles.integration.away3d.v4.initializers.A3D4CloneObject;
	import org.flintparticles.integration.away3d.v4.initializers.A3D4DisplayObject;
	import org.flintparticles.threeD.actions.Move;
	import org.flintparticles.threeD.actions.MutualGravity;
	import org.flintparticles.threeD.actions.RandomDrift;
	import org.flintparticles.threeD.actions.SpeedLimit;
	import org.flintparticles.threeD.emitters.Emitter3D;
	import org.flintparticles.threeD.initializers.Position;
	import org.flintparticles.threeD.initializers.Velocity;
	import org.flintparticles.threeD.zones.BoxZone;
	import org.flintparticles.threeD.zones.PointZone;

	final public class Sparklets extends Emitter3D {
		
		[Embed(source="../../../../../../assets/blurb256.png")]
		public static const Blur256:Class;
		
		[Embed(source="../../../../../../assets/blurb128.png")]
		public static const Blur128:Class;
		
		[Embed(source = "../../../../../../assets/blurb8.png")]
		public static const Blur8:Class;
		
		public static const SIZE_SMALL	:uint = 0;
		public static const SIZE_MEDIUM	:uint = 1;
		public static const SIZE_LARGE	:uint = 2;
		
		public var sineZone	:SineZone;
		
		public function Sparklets(){
			super();
			useInternalTick = false;
		}
		
		public function init(size:uint):void { 
			switch(size) {
				case SIZE_SMALL: initSmall(); break;
				case SIZE_MEDIUM: initMedium(); break;
				case SIZE_LARGE: initLarge(); break;
			}
		}
		
		private function initLarge():void {
			
			const zoneWidth		:uint = 1000;
			const zoneHeight	:uint = 320;
			const pCount		:Number = 0.1;
			const pLifeMax		:Number = 2; 
			const pLifeMin		:Number = 0.2; 
			const pvZ			:int = -50;
			
			const img:Bitmap = new Blur256();
			
			counter = new Random(0,pCount);
			addInitializer( new Lifetime( pLifeMin, pLifeMax ) );
			addInitializer( new Position( new BoxZone(zoneWidth, zoneHeight, 0, new Vector3D(), new Vector3D( 0, 1, 0 ), new Vector3D( 0, 0, 1 ) ) ) );
			addInitializer( new Velocity( new PointZone( new Vector3D( 0, 0, pvZ ) ) ) );
			
			addInitializer( new ColorsInit([0xffffffff, 0xff7f7f7f, 0xff6688dd, 0xff6688aa]));// 0x206620, 0x603020, 0, 0xFFFFFF, 0x80, 0x442288]) );
			addInitializer( new ScaleImagesInit([.5,3.5, 3.6, 3.7, 3.8, 3.9], [0.3, 0.1, 0.15, 0.1, 0.2, 0.2]));
			addInitializer( new A3D4CloneObject( new A3D4DisplayObject( img ).createImage() as Sprite3D, true, pCount ) );
			
			addAction( new Age( Quadratic.easeOut ) );
			addAction( new RandomDrift( 400, 400, 0 ) );
			addAction( new Move( ) );
			addAction( new TargetColor(0xffffff, 0.1 ) );
			addAction( new Fade( 1, 0 ) );
		}
		
		private function initMedium():void {
			
			const zoneWidth		:uint = 1200;
			const zoneHeight	:uint = 128;
			const pCount		:uint = 768;
			const pLifeMax		:Number = 5.5; 
			const pLifeMin		:Number = 0.1;
			const pvZ			:int = -50;
			
			const img:Bitmap = new Blur128();
			
			counter = new Steady( pCount );
			
			addInitializer( new Lifetime( pLifeMin, pLifeMax ) );
			addInitializer( new Position( sineZone = new SineZone(new Vector3D(zoneWidth, zoneHeight, 0), 0.5)));
			addInitializer( new Velocity( new PointZone( new Vector3D( 0, 0, pvZ ) ) ) );
			
			addInitializer( new ColorsInit([0xffffffff, 0xff7f7f7f, 0xff6688dd, 0xffdd6688]));
			//addInitializer( new ScaleImagesInit([0.2, 0.4, 0.6, 0.8, 1, 2], [0.1, 0.1, 0.05, 0.025 ,0.001, 0.001]));
			
			const ib:ImageInitializerBase = new A3D4CloneObject( new A3D4DisplayObject( img ).createImage() as Sprite3D);
			// filling this pool was taking a while and making the runtime hang for a bit too long...
			// so added fillPoolOverTime in ImageInitializerBase to allow pool filling spread over time
			ib.fillPoolOverTime(512, onPoolCreateComplete); 
			addInitializer( ib );
			
			addAction( new Age( Quadratic.easeIn ) );
			addAction( new Move( ) );
			addAction( new TargetColor(0xbbffbb, 0.1 ) );
			
			var scaleAction:ScaleImage;
			scaleAction = new ScaleImage( 0.025, 0.4 );
			addAction( scaleAction );
			
			addAction( new Fade( 1, 0 ) );
			addAction( new RandomDrift( 100, 75, 0 ) );
			addAction(  new MutualGravity( 4, 4 ) );
			
			addActivity( new UpdateOnFrame(new AudioActivity()) );
			addAction( new SpeedLimit( 140 ) );
		}
		
		private function onPoolCreateComplete():void {
			dispatchEvent(new Event("poolCreate"));
		}
		
		private function initSmall():void {
			
			const zoneWidth		:uint = 1800;
			const zoneHeight	:uint = 1000;
			const pCount		:uint = 64;
			const pLifeMax		:Number = 0.7; 
			const pLifeMin		:Number = 0.2;
			const pvZ			:int = -50;
			
			const img:Bitmap = new Blur8();
			
			counter = new Steady( pCount );
			
			addInitializer( new Lifetime( pLifeMin, pLifeMax ) );
			addInitializer( new Position( new BoxZone(zoneWidth, zoneHeight, 0, new Vector3D(), new Vector3D( 0, 1, 0 ), new Vector3D( 0, 0, 1 ) ) ) );
			addInitializer( new Velocity( new PointZone( new Vector3D( 0, 0, pvZ ) ) ) );
			
			addInitializer( new ColorsInit([0xffffffff, 0x7f7f7f7f, 0xff6688dd, 0xffdd6688]));// 0x206620, 0x603020, 0, 0xFFFFFF, 0x80, 0x442288]) );
			addInitializer( new A3D4CloneObject( new A3D4DisplayObject( img ).createImage() as Sprite3D, true, pCount ) );
			
			addAction( new Age( Quadratic.easeIn ) );
			addAction( new Move( ) );
			addAction( new TargetColor(0xffffff, 0.1 ) );
			addAction( new ScaleImage( 1, 2.33 ) );
			addAction( new Fade( 1, 0 ) );
			//addAction( new RandomDrift( 150, 150, 0 ) );
	
		}
	}
}
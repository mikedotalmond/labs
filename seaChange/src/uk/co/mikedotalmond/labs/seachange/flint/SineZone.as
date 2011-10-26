package uk.co.mikedotalmond.labs.seachange.flint {
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	
	import flash.geom.Vector3D;
	import org.flintparticles.threeD.zones.Zone3D;
	
	public final class SineZone implements Zone3D {
		
		/**
		 * 2D Vector of points describing a series of steps through the xyz functions
		 */
		private var _data	:Vector.<Vector3D>;
		private var _v		:Vector3D;
		
		public var size		:Vector3D;
		
		public var scaleX	:Number = 1;
		public var scaleY	:Number = 1;
		
		public function SineZone(size:Vector3D, resolution:Number = 1) {
			this.size				= size;
			_v 						= new Vector3D();
			var stepsX	:int 		= int(Math.round(size.x * resolution));
			var stepX	:Number 	= size.x / stepsX;
			var _aY		:Number 	= size.y;
			var _aZ		:Number 	= size.z;			
			var m		:int;
			
			_data = new Vector.<Vector3D>(m = stepsX, true);
			while (--m > -1) {
				_data[m] = new Vector3D(m * stepX - size.x / 2, (_aY * Math.sin(0.025 * m + 0.4)) , (_aZ * Math.sin(0.05 * m)));
			}
		}
		
		/* INTERFACE org.flintparticles.threeD.zones.Zone3D */
		public function contains(p:Vector3D):Boolean {
			return false;
		}
		
		public function getLocation():Vector3D {
			_v.copyFrom(_data[int(Math.random() * _data.length)] as Vector3D);
			_v.x *= scaleX;
			_v.y *= scaleY;
			return _v;
		}
		
		public function getVolume():Number {
			return _data.length;
		}
	}
}
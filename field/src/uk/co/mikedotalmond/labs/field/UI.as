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
	
	import com.bit101.components.CheckBox;
	import com.bit101.components.HUISlider;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.Style;
	import com.bit101.components.UISlider;
	import com.greensock.easing.Strong;
	import com.greensock.TweenMax;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Mike Almond - https://twitter.com/#!/mikedotalmond
	 */
	public final class UI extends Panel {
		
		public var label:Label;
		
		public var gravityXToggle:CheckBox;
		public var gravityXSlider:HUISlider;
		
		public var gravityYToggle:CheckBox;
		public var gravityYSlider:HUISlider;
		
		public var perlinXToggle:CheckBox;
		public var perlinXSlider:HUISlider;
		
		public var perlinYToggle:CheckBox;
		public var perlinYSlider:HUISlider;
		
		public var perlinSeedSlider:HUISlider;
		
		public var fieldToggle:CheckBox;
		public var fieldSlider:HUISlider;
		public var perlinSeedToggle:CheckBox;
		
		public function UI(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0) {
			Style.LABEL_TEXT = 0;
			
			super(parent, xpos, ypos);
			setSize(370, 117);
			y = ypos - height;
		}
		
		override protected function addChildren():void {
			super.addChildren();
			_background.alpha = 0.9;
			
			label = new Label(content, 4, 1, "show / hide - controls c | stats s | fullscreen f");
			
			gravityXToggle = new CheckBox(content, 325, 21, "tween", onToggle);
			gravityXSlider = new HUISlider(content, 5, 5, "gravity x", null);
			gravityXSlider.minimum = -400;
			gravityXSlider.maximum = 400;
			gravityXSlider.width = 340;
			gravityXSlider.labelPrecision = 0;
			gravityXSlider.y = 17;
			
			gravityYToggle = new CheckBox(content, 325, 37, "tween", onToggle);
			gravityYSlider = new HUISlider(content, 5, 5, "gravity y", null);
			gravityYSlider.minimum = -400;
			gravityYSlider.maximum = 400;
			gravityYSlider.width = 340;
			gravityYSlider.labelPrecision = 0;
			gravityYSlider.y = 33;
			
			perlinXToggle = new CheckBox(content, 325, 52, "tween", onToggle);
			perlinXSlider = new HUISlider(content, 5, 5, "perlin x", null);
			perlinXSlider.minimum = -4;
			perlinXSlider.maximum = 4;
			perlinXSlider.width = 340;
			perlinXSlider.labelPrecision = 1;
			perlinXSlider.y = 48;			
			
			perlinYToggle = new CheckBox(content, 325, 68, "tween", onToggle);
			perlinYSlider = new HUISlider(content, 5, 5, "perlin y", null);
			perlinYSlider.minimum = -4;
			perlinYSlider.maximum = 4;
			perlinYSlider.width = 340;
			perlinYSlider.labelPrecision = 1;
			perlinYSlider.y = 64;	
			
			fieldToggle = new CheckBox(content, 325, 82, "tween", onToggle);
			fieldSlider = new HUISlider(content, 5, 5, "perlin force", null);
			fieldSlider.minimum = -8;
			fieldSlider.maximum = 8;
			fieldSlider.width = 340;
			fieldSlider.labelPrecision = 1;
			fieldSlider.y = 79;
			
			perlinSeedToggle = new CheckBox(content, 325, 99, "tween", onToggle);
			perlinSeedSlider = new HUISlider(content, 5, 5, "perlin seed", null);
			perlinSeedSlider.minimum = 1;
			perlinSeedSlider.maximum = 128;
			perlinSeedSlider.width = 340;
			perlinSeedSlider.labelPrecision = 0;
			perlinSeedSlider.y = 95;
			
			gravityXToggle.selected = gravityYToggle.selected = 
			perlinXToggle.selected = perlinYToggle.selected = 
			perlinSeedToggle.selected = fieldToggle.selected = true;
			
			automateSlider(gravityXSlider, 8);
			automateSlider(gravityYSlider, 7);
			automateSlider(perlinXSlider, 6);
			automateSlider(perlinYSlider, 5);
			automateSlider(perlinSeedSlider, 60);
			automateSlider(fieldSlider, 12);
		}
		
		private function onToggle(e:Event):void {
			const selected:Boolean = !(e.target as CheckBox).selected;
			switch(e.target) {
				case gravityXToggle		: selected ? TweenMax.killTweensOf(gravityXSlider) 	: automateSlider(gravityXSlider, 8); break;
				case gravityYToggle		: selected ? TweenMax.killTweensOf(gravityYSlider) 	: automateSlider(gravityYSlider, 7); break;
				case perlinXToggle		: selected ? TweenMax.killTweensOf(perlinXSlider) 	: automateSlider(perlinXSlider, 6); break;
				case perlinYToggle		: selected ? TweenMax.killTweensOf(perlinYSlider) 	: automateSlider(perlinYSlider, 5); break;
				case perlinSeedToggle	: selected ? TweenMax.killTweensOf(perlinSeedSlider): automateSlider(perlinSeedSlider, 120); break;
				case fieldToggle		: selected ? TweenMax.killTweensOf(fieldSlider) 	: automateSlider(fieldSlider, 12); break;
			}
		}
		
		public static function automateSlider(slider:UISlider, time:Number, direction:int=1):void {
			var e:Event  = new Event(Event.CHANGE);
			slider.value = direction == 1 ? slider.minimum : slider.maximum;
			TweenMax.to(slider, time, {	value:direction == 1 ? slider.maximum : slider.minimum, 
										onUpdate:slider.dispatchEvent, onUpdateParams:[e],
										onComplete:automateSlider, onCompleteParams:[slider, time, -direction],
										ease:Strong.easeInOut } );
			
		}
	}
}
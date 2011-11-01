/*
Copyright (c) 2011 Mike Almond - @mikedotalmond

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

package uk.co.mikedotalmond.labs.cartest.ui {
	
	/**
	 * ...
	 * @author Mike Almond
	 */
	
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Label;
	import com.bit101.components.Panel;
	import com.bit101.components.Component;
	import com.bit101.components.ColorChooser;
	import com.bit101.components.PushButton;
	import com.bit101.components.Style;
	import flash.display.BlendMode;
	
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.DisplayObjectContainer;
	
	public final class Controls extends Panel {
		
		private var _skidPicker:ColourPicker;
		private var _bgPicker:ColourPicker;
		public var skidColour:uint;
		
		public function Controls(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0):void {
			super(parent, xpos, ypos);
			setSize(295, 20);
			
			_background.alpha	= 0.4;
			Style.LABEL_TEXT	= 0x333333;
			
			_skidPicker = new ColourPicker(content, 2, 1, onSkidColour, "skids");
			
			_skidPicker.value 	= 0x050506;
			
			var box:CheckBox = new CheckBox(this, 144, 3, "noby noby", onNoby);
			
			var button:PushButton;
			
			button = new PushButton(content, 210, 1, "clear", onClear);
			button.setSize(40, 16);
			
			button = new PushButton(content, 252, 1, "save", onSave);
			button.setSize(40, 16);
			
			stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			onResize(null);
		}
		
		private function onClear(e:Event):void{
			dispatchEvent(new Event("clear"));
		}
		
		private function onSave(e:Event):void{
			dispatchEvent(new Event("save"));
		}
		
		private function onNoby(e:Event):void {
			const s:Boolean = CheckBox(e.target).selected;
			s ? addEventListener(Event.ENTER_FRAME, doNoby, false, 0, true) : removeEventListener(Event.ENTER_FRAME, doNoby);
			_skidPicker.mouseEnabled = !s;
		}
		
		private function doNoby(e:Event):void {
			_skidPicker.onRandom(null);
		}
		
		private function onSkidColour():void {
			skidColour = _skidPicker.value;
			dispatchEvent(new Event("skidColourSelect"));
		}
		
		private function onResize(e:Event):void {
			y = stage.stageHeight - 20;
		}
	}
}

import com.bit101.components.ColorChooser;
import com.bit101.components.Label;
import com.bit101.components.PushButton;
import flash.display.DisplayObjectContainer;
import flash.events.Event;

internal class ColourPicker {
	
	private var label:Label;
	private var button:PushButton;
	private var picker:ColorChooser;
	private var _defaultHandler:Function;
	
	public function get value():uint {
		return picker.value;
	}
	public function set value(val:uint):void {
		picker.value = val;
	}
	
	public function set mouseEnabled(value:Boolean):void {
		picker.mouseEnabled = button.mouseEnabled = value;
	}
	
	public function ColourPicker(container:DisplayObjectContainer, x:int, y:int, defaultHandler:Function, labl:String = "picker"):void {
		
		_defaultHandler = defaultHandler;
		
		label = new Label(container, x, y, labl);
		
		picker = new ColorChooser(container, label.x + label.width, y, 0x050506, onChange);
		picker.popupAlign 	= ColorChooser.TOP;
		picker.usePopup   	= true;
		
		button = new PushButton(container, picker.x + picker.width + 5, y, "random", onRandom);
		button.setSize(45, 17);
	}
	
	private function onChange(e:Event):void{
		_defaultHandler.call();
	}
	
	internal function onRandom(e:Event):void {
		picker.value = (Math.random() * 0xFF << 16) | (Math.random() * 0xFF << 8) | (Math.random() * 0xFF);
		_defaultHandler.call();
	}
}
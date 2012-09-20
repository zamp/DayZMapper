package  
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.furusystems.logging.slf4as.Logging;
	import flash.display.CapsStyle;
	import flash.display.JointStyle;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author zamp
	 */
	public class ObjectIcon extends Sprite
	{
		private var _id:int = -1;
		private var _tooltip:Sprite;
		private var _maxAge:Number = 604800; // a week
		
		private var _oldpositions:Vector.<Point> = new Vector.<Point>;
		
		private var _data:XML;
		
		[Embed(source="pf_tempesta_seven.ttf", fontName="pf_tempesta", mimeType = "application/x-font", embedAsCFF = "false")]
		static public var font_pftempesta:Class;
		
		public function ObjectIcon(data:XML) 
		{
			_id = data.id;
			_data = data;
			
			mouseChildren = false;
			
			var coords:Point = Main.convertCoords(data.x, data.y);
			updateGraphic(coords.x,coords.y);
			
			//updateAlpha(data.age);
			
			_oldpositions.unshift(coords.clone());
			
			buildTooltip(data, coords);
			
			addEventListener(MouseEvent.ROLL_OVER, mouseOver);
			addEventListener(MouseEvent.ROLL_OUT, mouseOut);
		}
		
		private function buildTooltip(data:XML, coords:Point, clicked:Boolean = false):void 
		{
			if (_tooltip != null)
				Main.instance.map.removeChild(_tooltip);
				
			_tooltip = new Sprite();
			_tooltip.mouseEnabled = false;
			_tooltip.mouseChildren = false;
			
			var tf:TextField = new TextField();
			tf.embedFonts = true;
			tf.defaultTextFormat = new TextFormat("pf_tempesta", 8, 0xffffff);			
			tf.filters = [new DropShadowFilter(0, 0, 0x000000, 1, 2, 2, 5)];
			tf.textColor = 0xFFFFFF;
			tf.x = 2;
			tf.y = 0;
			tf.width = 100;
			tf.height = 1000;
			tf.selectable = false;
			tf.multiline = true;
			tf.htmlText = data.otype + "\n";
			
			var inv:Array = JSON.decode(data.inventory);
			//Logging.getLogger(PlayerIcon).info(inv);
			for (var i:int = 0; i < inv.length; ++i)
			{
				for (var j:int = 0; j < inv[i][0].length; ++j)
				{
					tf.htmlText += inv[i][1][j] + "x " + inv[i][0][j] + "\n";
				}
			}
			_tooltip.x = coords.x;
			_tooltip.y = coords.y - (tf.textHeight + 3);
			
			_tooltip.graphics.beginFill(0x223344, 0.7);
			_tooltip.graphics.lineStyle(1, 0x000000, 0.7);
			_tooltip.graphics.drawRect(0, 0, tf.textWidth + 7, tf.textHeight + 3);
			
			_tooltip.addChild(tf);
			_tooltip.alpha = 0;
			
			Main.instance.map.addChild(_tooltip);
		}
		
		private function mouseOut(e:MouseEvent):void 
		{
			_tooltip.alpha = 0;
		}
		
		private function mouseOver(e:MouseEvent):void 
		{
			_tooltip.alpha = 1;
		}

		private function updateGraphic(x:Number, y:Number):void 
		{
			var color:uint = 0xE0AE22;
			graphics.clear();
			// draw shit
			/*if (_oldpositions.length > 1)
			{
				graphics.lineStyle(2, color, 0.6, true, "normal", CapsStyle.ROUND, JointStyle.BEVEL);
				graphics.moveTo(x, y);
				for each (var p:Point in _oldpositions)
					graphics.lineTo(p.x, p.y);
			}*/
			
			graphics.lineStyle(1, 0x000000, 1);
			graphics.beginFill(color, 1);
			graphics.drawRect(x, y, 5, 5);
			graphics.endFill();
		}
		
		public function newData(data:XML):void
		{
			var coords:Point = Main.convertCoords(data.x, data.y);
			updateGraphic(coords.x,coords.y);
			
			buildTooltip(data, coords);
			
			_oldpositions.unshift(coords.clone());
		}
		
		public function get id():int 
		{
			return _id;
		}
		
	}

}
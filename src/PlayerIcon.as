package  
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.furusystems.logging.slf4as.Logging;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
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
	public class PlayerIcon extends Sprite
	{
		private var _id:String = "";
		private var _tooltip:Sprite;
		private var _maxAge:Number = 300; // an hour
		
		private var _oldpositions:Vector.<Point> = new Vector.<Point>;
		
		// list of weapons that will show up in player tooltip
		private var weapons:Array = [
			"M14_EP1", "Remington870_lamp", "M4A3_CCO_EP1", "M4A1_AIM_SD_camo", "BAF_L85A2_RIS_CWS", "BAF_AS50_scoped", "Winchester1866", "LeeEnfield",
			"revolver_EP1", "FN_FAL", "FN_FAL_ANPVS4", "Mk_48_DZ", "DMR", "M16A2", "M16A2GL", "bizon_silenced", "AK_74", "M4A1_Aim",  "AKS_74_kobra",
			"AKS_74_U",  "AK_47_M", "M24", "M1014", "M4A1", "MP5SD", "MP5A5", "huntingrifle", "Crossbow", "glock17_EP1", "M9", "M9SD", "Colt1911", "UZI_EP1",
			"m16a4_acg", "SVD_Camo", "M107_DZ"
		];
		
		// list of key items that will show up in player tooltip
		private var keyItems:Array = [
			"Binocular_Vector",
			"NVGoggles",
			"ItemGPS",
			"ItemTent"
		];
		
		
		private var _data:XML;
		
		[Embed(source="pf_tempesta_seven.ttf", fontName="pf_tempesta", mimeType = "application/x-font", embedAsCFF = "false")]
		static public var font_pftempesta:Class;
		
		private var _line:Sprite = new Sprite();
		private var _icon:Sprite = new Sprite();
		private var _lastPos:Point = new Point();
		private var _size:Number = 6;
		
		public function PlayerIcon(data:XML) 
		{
			_id = data.id;
			_data = data;
			this.name = data.name;
			
			mouseChildren = false;
			
			var coords:Point = Main.convertCoords(data.x, data.y);
			updateGraphic(coords.x,coords.y,0xFF0000);
			
			updateAlpha(data.age);
			
			_oldpositions.unshift(coords.clone());
			
			buildTooltip(data, coords);
			
			addChild(_line);
			_line.alpha = 0.5;
			
			if (Main.instance.icons)
				_icon.addChild(new Assets.rIconPlayer);
			else {
				var c:uint = 0xFF0000;
				_icon.graphics.beginFill(c, 1);
				_icon.graphics.lineStyle(1, c/2, 1);
				_icon.graphics.drawCircle( -_size / 2, -_size / 2, _size);
				_icon.graphics.endFill();
			}
			addChild(_icon);
			
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
			//tf.filters = [new DropShadowFilter(0, 0, 0x000000, 1, 2, 2, 5)];
			tf.textColor = 0xFFFFFF;
			tf.x = 2;
			tf.y = 0;
			tf.width = 120;
			tf.height = 1000;
			tf.selectable = false;
			tf.multiline = true;
			tf.htmlText = data.name + " <font color=\"#80ff80\">" + data.model + "</font>\n";
			var humanity:Number = data.humanity;
			if (humanity < 0)
				tf.htmlText += "Humanity: <font color=\"#ff4040\">" + data.humanity + "</font>\n";
			else
				tf.htmlText += "Humanity: <font color=\"#40ff40\">" + data.humanity + "</font>\n";
			
			tf.htmlText += "Bandit kills: " + data.bkills + "\n";
			tf.htmlText += "Survivor kills: " + data.hkills + "\n";
			var inv:Array = JSON.decode(data.inventory);
			//Logging.getLogger(PlayerIcon).info(inv);
			if (inv.length > 1)
			{
				for (var i:int = 0; i < inv[0].length; ++i)
					if (weapons.indexOf(inv[0][i]) != -1)
						tf.htmlText += "<font color=\"#ff4040\">" + inv[0][i] + "</font>\n";
				
				for (i = 0; i < inv[0].length; ++i)
					if (keyItems.indexOf(inv[0][i]) != -1)
						tf.htmlText += "<font color=\"#8080ff\">" + inv[0][i] + "</font>\n";
			}
			
			_tooltip.x = Math.floor(coords.x + 10);
			_tooltip.y = Math.floor(coords.y);
			
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
			TweenLite.to(_line, 1, { alpha:0.5 } );
		}
		
		private function mouseOver(e:MouseEvent):void 
		{
			_tooltip.alpha = 1;
			TweenLite.to(_line, 0.3, { alpha:1 } );
		}
		
		private function countHumanity(h:Number):uint
		{
			if (h > 5000)
				return 0x0000FF;
			else if (h < 0)
				return 0xFF00FF;
			return 0xFF0000;
		}
		
		private function updateGraphic(x:Number, y:Number, color:uint):void 
		{
			// draw new line piece
			if (_lastPos.x != 0 && _lastPos.y != 0)
			{
				_line.graphics.lineStyle(2, color, 0.6, true);
				_line.graphics.moveTo(_lastPos.x, _lastPos.y);
				_line.graphics.lineTo(x, y);
			}
			_lastPos.x = x;
			_lastPos.y = y;
			
			_icon.x = x;
			_icon.y = y;
		}
		
		public function newData(data:XML):void
		{
			var coords:Point = Main.convertCoords(data.x, data.y);
			updateGraphic(coords.x,coords.y,0xFF0000);
			
			updateAlpha(data.age);
			buildTooltip(data, coords);
			
			if (coords.length > 1)
				_oldpositions.unshift(coords.clone());
		}
		
		private function updateAlpha(age:Number):void 
		{
		}
		
		public function get id():String
		{
			return _id;
		}
		
		public function get icon():Sprite 
		{
			return _icon;
		}
		
		public function get tooltip():Sprite 
		{
			return _tooltip;
		}
		
	}

}
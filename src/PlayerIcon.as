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
	public class PlayerIcon extends Sprite
	{
		private var _id:int = -1;
		private var _tooltip:Sprite;
		private var _maxAge:Number = 300; // an hour
		
		private var _oldpositions:Vector.<Point> = new Vector.<Point>;
		
		private var weapons:Array = [
			"M14_EP1", "Remington870_lamp", "M4A3_CCO_EP1", "M4A1_AIM_SD_camo", "BAF_L85A2_RIS_CWS", "BAF_AS50_scoped", "Winchester1866", "LeeEnfield",
			"revolver_EP1", "FN_FAL", "FN_FAL_ANPVS4", "m107_DZ", "Mk_48_DZ", "DMR", "M16A2", "M16A2GL", "bizon_silenced", "AK_74", "M4A1_Aim",  "AKS_74_kobra",
			"AKS_74_U",  "AK_47_M", "M24", "M1014", "M4A1", "MP5SD", "MP5A5", "huntingrifle", "Crossbow", "glock17_EP1", "M9", "M9SD", "Colt1911", "UZI_EP1",
			"m16a4_acg", "SVD_Camo"
		];
		
		private var keyItems:Array = [
			"Binocular_Vector",
			"NVGoggles",
			"ItemGPS",
			"ItemTent"
		];
		
		private var _data:XML;
		
		[Embed(source="pf_tempesta_seven.ttf", fontName="pf_tempesta", mimeType = "application/x-font", embedAsCFF = "false")]
		static public var font_pftempesta:Class;
		
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
			
			tf.htmlText += "Kills: " + data.hkills + "/" + data.bkills + "\n";			
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
			graphics.clear();
			// draw shit
			if (_oldpositions.length > 1)
			{
				graphics.lineStyle(2, color, 0.6, true, "normal", CapsStyle.ROUND, JointStyle.BEVEL);
				graphics.moveTo(x, y);
				for each (var p:Point in _oldpositions)
					graphics.lineTo(p.x, p.y);
			}
			
			graphics.lineStyle(1, 0x000000, 1);
			graphics.beginFill(color, 1);
			graphics.drawCircle(x, y, 3);
			graphics.endFill();
		}
		
		public function newData(data:XML):void
		{
			var coords:Point = Main.convertCoords(data.x, data.y);
			updateGraphic(coords.x,coords.y,0xFF0000);
			
			updateAlpha(data.age);
			buildTooltip(data, coords);
			
			_oldpositions.unshift(coords.clone());
		}
		
		private function updateAlpha(age:Number):void 
		{
			var a:Number = (_maxAge + age) / _maxAge;
			a = a < 0 ? 0 : a;
			alpha = a;
		}
		
		public function get id():int 
		{
			return _id;
		}
		
	}

}
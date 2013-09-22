package  
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	import com.furusystems.logging.slf4as.Logging;
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
	public class DeployableIcon extends Sprite
	{
		private var _id:int = -1;
		private var _tooltip:Sprite;
		private var _maxAge:Number = 604800; // a week
		
		private var _oldpositions:Vector.<Point> = new Vector.<Point>;
		
		private var _data:XML;
		private var _icon:Sprite = new Sprite();
		
		private var _size:Number = 6;
		
		[Embed(source="pf_tempesta_seven.ttf", fontName="pf_tempesta", mimeType = "application/x-font", embedAsCFF = "false")]
		static public var font_pftempesta:Class;
		
		public function DeployableIcon(data:XML) 
		{
			_id = data.id;
			_data = data;
			
			mouseChildren = false;
			
			var coords:Point = Main.convertCoords(data.x, data.y);
			updateGraphic(coords.x,coords.y);
			
			//updateAlpha(data.age);
			
			_oldpositions.unshift(coords.clone());
			
			buildTooltip(data, coords);
			
			var c:uint = 0xFFFFFF;
			
			switch (String(data.otype))
			{
				case "TentStorage":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTent);
					else 
						c = 0x00AA00;
				break;
				case "StashSmall":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconStashSmall);
					else 
						c = 0x00AA00;
				break;
				case "StashMedium":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconStashMedium);
					else 
						c = 0x00AA00;
				break;
				case "Wire_cat1":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconFence);
					else 
						c = 0x404040;
				break;
				case "Hedgehog_DZ":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "Sandbag1_DZ":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconBag);
					else 
						c = 0x404040;
				break;
				case "DomeTentStorage":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTent);
					else 
						c = 0x404040;
				break;
				case "CamoNet_DZ":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconCamoNet);
					else 
						c = 0x404040;
				break;
				case "Trap_Cans":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "TrapTripwireFlare":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "TrapBearTrapSmoke":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "TrapTripwireGrenade":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "TrapBearTrapSmoke":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "TrapTripwireSmoke":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
				case "TrapBearTrapFlare":
					if (Main.instance.icons)
						_icon.addChild(new Assets.rIconTrap);
					else 
						c = 0x404040;
				break;
			}
			
			if (!Main.instance.icons)
			{
				_icon.graphics.beginFill(c, 1);
				_icon.graphics.lineStyle(1, c/2, 1);
				_icon.graphics.drawRect( -_size / 2, -_size / 2, _size, _size);
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
			_tooltip.x = Math.floor(coords.x + 10);
			_tooltip.y = Math.floor(coords.y);
			
			_tooltip.graphics.beginFill(0x223344, 0.7);
			_tooltip.graphics.lineStyle(1, 0x000000, 0.7);
			_tooltip.graphics.drawRect(0, 0, tf.textWidth + 7, tf.textHeight + 3);
			
			_tooltip.addChild(tf);
			_tooltip.alpha = 0;
			_tooltip.scaleX = 1 / Main.instance.map.scaleX;
			_tooltip.scaleY = 1 / Main.instance.map.scaleY;
			
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
			_icon.x = x;
			_icon.y = y;
			_icon.scaleX = 1 / Main.instance.map.scaleX;
			_icon.scaleY = 1 / Main.instance.map.scaleY;
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
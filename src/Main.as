package 
{
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.logging.slf4as.Logging;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.net.SharedObject;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author zamp
	 */
	public class Main extends Sprite 
	{
		// TODO: when you click on someone you follow them automatically.
		
		static public const IMAGE_WIDTH:Number = 2000;
		static public const IMAGE_HEIGHT:Number = 2000;
		static public const LINGOR:Boolean = true;
		
		[Embed(source="map_lingor.jpg")]
		private var _mapSource:Class;
		
		private var _map:Sprite;
		private var _xmlUrl:String = "data.php";
		private var _players:Vector.<PlayerIcon> = new Vector.<PlayerIcon>;
		private var _timer:Timer = new Timer(10000);
		private var _objects:Vector.<ObjectIcon> = new Vector.<ObjectIcon>;
		private var _loadingTF:TextField;
		
		public static var instance:Main;
		
		public function Main():void 
		{
			instance = this;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			// entry point
			
			_map = new Sprite();
			_map.addChild(new _mapSource());
			
			var derp:SharedObject = SharedObject.getLocal("mapPos");
			if (derp.data.mapX != null)
				_map.x = derp.data.mapX;
			if (derp.data.mapY != null)
				_map.y = derp.data.mapY;
			
			_map.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_map.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			addChild(_map);
			
			// pull data from server
			addChild(DConsole.view);
			
			_loadingTF = new TextField();
			_loadingTF.embedFonts = true;
			_loadingTF.defaultTextFormat = new TextFormat("pf_tempesta", 8, 0xffffff);			
			_loadingTF.filters = [new DropShadowFilter(0, 0, 0x000000, 1, 2, 2, 5)];
			_loadingTF.textColor = 0xFFFFFF;
			_loadingTF.x = 5;
			_loadingTF.y = 2;
			_loadingTF.width = 100;
			_loadingTF.height = 1000;
			_loadingTF.selectable = false;
			_loadingTF.multiline = true;
			_loadingTF.htmlText = "";
			addChild(_loadingTF);
			
			_timer.addEventListener(TimerEvent.TIMER, loadDataXml);
			_timer.start();
			loadDataXml();
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			_map.stopDrag();
			
			var derp:SharedObject = SharedObject.getLocal("mapPos");
			derp.data.mapX = _map.x;
			derp.data.mapY = _map.y;
			derp.flush();
		}
		
		private function mouseDown(e:MouseEvent):void 
		{
			_map.startDrag();
		}
		
		private function loadDataXml(event:Event = null):void
		{
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR , xmlFail);
			loader.load(new URLRequest(_xmlUrl));
			_loadingTF.text = "Refreshing data...";
		}
		
		private function xmlFail(e:IOErrorEvent):void 
		{
			Logging.getLogger(Main).error("Couldn't fetch xml file");
			_loadingTF.text = "Refresh failed.";
		}
		
		private function xmlLoaded(e:Event):void 
		{
			_loadingTF.text = "";
			Logging.getLogger(Main).error("I got something");
			
			var xml:XML = new XML(e.target.data);
			
			//Logging.getLogger(Main).info(xml);
			
			for each (var player:XML in xml.player)
			{
				// search for icon with the same id
				var found:Boolean = false;
				var id:int = player.id;				
				for each (var pi:PlayerIcon in _players)
				{
					if (pi.id == id)
					{
						found = true;
						
						// update data
						pi.newData(player);
					}
				}
				
				// if we didnt find one, add icon to list and as a child
				if (!found)
				{
					pi = new PlayerIcon(player);
					pi.mouseChildren = false;
					_map.addChild(pi);
					_players.push(pi);
				}
			}
			
			for each (var object:XML in xml.object)
			{
				// search for icon with the same id
				found = false;
				id = object.id;				
				for each (var obj:ObjectIcon in _objects)
				{
					if (obj.id == id)
					{
						found = true;
						
						// update data
						obj.newData(object);
					}
				}
				
				// if we didnt find one, add icon to list and as a child
				if (!found)
				{
					obj = new ObjectIcon(object);
					obj.mouseChildren = false;
					_map.addChild(obj);
					_objects.push(obj);
				}
			}
		}
		
		public function get map():Sprite 
		{
			return _map;
		}
		
		public static function convertCoords(x:Number, y:Number):Point
		{
			if (LINGOR)
			{
				//x += 700;
				y -= 5365;
				
				x = x / 10000 * Main.IMAGE_WIDTH;
				y = y / 10000 * Main.IMAGE_HEIGHT;
				
				return new Point(Math.floor(x), Math.floor(y));
			}
			else 
			{
				x -= 700;
				y -= 370;
				
				x = x / 14300 * Main.IMAGE_WIDTH;
				y = y / 13850 * Main.IMAGE_HEIGHT;
				
				return new Point(Math.floor(x), Math.floor(y));
			} 
			return new Point();
		}
		
	}
	
}
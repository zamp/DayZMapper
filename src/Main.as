package 
{
	import com.furusystems.dconsole2.DConsole;
	import com.furusystems.dconsole2.plugins.ScreenshotUtil;
	import com.furusystems.logging.slf4as.Logging;
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
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
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author zamp
	 */
	public class Main extends Sprite 
	{
		// TODO: when you click on someone you follow them automatically.		
		public static var IMAGE_WIDTH:Number = 0;
		public static var IMAGE_HEIGHT:Number = 0;
		public static var OFFSET_X:Number = 0;
		public static var OFFSET_Y:Number = 0;
		public static var SCALE_X:Number = 0;
		public static var SCALE_Y:Number = 0;
		
		private var _map:Sprite;
		private var _xmlUrl:String = "data.php";
		private var _mapUrl:String = "map.txt";
		private var _players:Vector.<PlayerIcon> = new Vector.<PlayerIcon>;
		private var _timer:Timer = new Timer(10000);
		private var _vehicles:Vector.<VehicleIcon> = new Vector.<VehicleIcon>;
		private var _deployables:Vector.<DeployableIcon> = new Vector.<DeployableIcon>;
		private var _loadingTF:TextField;
		private var _showPlayers:Boolean = true;
		private var _showBags:Boolean = true;
		private var _showTents:Boolean = true;
		private var _showVehicles:Boolean = true;
		private var _showFences:Boolean = true;
		private var _showTraps:Boolean = true;
		private var _icons:Boolean = true;
		
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
			_map.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			_map.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			addChild(_map);
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, wheel);
			
			// pull data from server
			addChild(DConsole.view);
			DConsole.registerPlugins(ScreenshotUtil);
			
			_loadingTF = new TextField();
			_loadingTF.embedFonts = true;
			_loadingTF.defaultTextFormat = new TextFormat("pf_tempesta", 8, 0xffffff);			
			_loadingTF.filters = [new DropShadowFilter(0, 0, 0x000000, 1, 2, 2, 5)];
			_loadingTF.textColor = 0xFFFFFF;
			_loadingTF.x = 5;
			_loadingTF.y = 2;
			_loadingTF.width = 1000;
			_loadingTF.height = 1000;
			_loadingTF.selectable = false;
			_loadingTF.multiline = true;
			_loadingTF.htmlText = "";
			addChild(_loadingTF);
			_loadingTF.mouseEnabled = false;
			
			// get file with map
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, mapConfigLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR , xmlFail);
			loader.load(new URLRequest(_mapUrl));
			_loadingTF.text = "Loading map.txt";
			
			// add icons to toggle what is shown
			var n:Number = 0;
			addButton(togglePlayers, 5 + n * 18, 5, new Assets.rIconPlayer); n++;
			addButton(toggleVehicles, 5 + n * 18, 5, new Assets.rIconCar); n++;
			addButton(toggleTents, 5 + n * 18, 5, new Assets.rIconTent); n++;
		}
		
		protected function scaleAround(offsetX:Number, offsetY:Number, absScaleX:Number, absScaleY:Number):void 
		{ 
			// scaling will be done relatively 
			var relScaleX:Number = absScaleX / _map.scaleX; 
			var relScaleY:Number = absScaleY / _map.scaleY; 
			// map vector to centre point within parent scope 
			var AC:Point = new Point( offsetX, offsetY ); 
			AC = _map.localToGlobal( AC ); 
			AC = _map.parent.globalToLocal( AC ); 
			// current registered postion AB 
			var AB:Point = new Point( _map.x, _map.y ); 
			// CB = AB - AC, this vector that will scale as it runs from the centre 
			var CB:Point = AB.subtract( AC ); 
			CB.x *= relScaleX; 
			CB.y *= relScaleY; 
			// recaulate AB, this will be the adjusted position for the clip 
			AB = AC.add( CB ); 
			// set actual properties 
			_map.scaleX *= relScaleX; 
			_map.scaleY *= relScaleY; 
			_map.x = AB.x; 
			_map.y = AB.y;
		}
		
		private function wheel(e:MouseEvent):void 
		{
			var s:Number = _map.scaleX + (e.delta / 8);
			s = s < 0.5 ? 0.5 : s;
			s = s > 4 ? 4 : s;
			scaleAround(e.localX, e.localY, s, s);
			scaleIcons();
		}
		
		private function scaleIcons():void 
		{
			for each (var d:DeployableIcon in _deployables)
			{
				d.icon.scaleX = 1 / _map.scaleX;
				d.icon.scaleY = 1 / _map.scaleY;
				d.tooltip.scaleX = 1 / _map.scaleX;
				d.tooltip.scaleY = 1 / _map.scaleX;
			}
			for each (var v:VehicleIcon in _vehicles)
			{
				v.icon.scaleX = 1 / _map.scaleX;
				v.icon.scaleY = 1 / _map.scaleY;
				v.tooltip.scaleX = 1 / _map.scaleX;
				v.tooltip.scaleY = 1 / _map.scaleX;
			}
			for each (var p:PlayerIcon in _players)
			{
				p.icon.scaleX = 1 / _map.scaleX;
				p.icon.scaleY = 1 / _map.scaleY;
				p.tooltip.scaleX = 1 / _map.scaleX;
				p.tooltip.scaleY = 1 / _map.scaleX;
			}
		}
		
		private function toggleTents(e:Event):void 
		{
			_showTents = !_showTents;
			hideShowStuff();
		}
		
		private function toggleVehicles(e:Event):void 
		{
			_showVehicles = !_showVehicles;
			hideShowStuff();
		}
		
		private function togglePlayers(e:Event):void 
		{
			_showPlayers = !_showPlayers;
			hideShowStuff();
		}
		
		private function hideShowStuff():void 
		{
			if (_showTents)
			{
				for each (var d:DeployableIcon in _deployables)
					TweenLite.to(d, 1, { alpha:1 } );
			} else {
				for each (d in _deployables)
					TweenLite.to(d, 1, { alpha:0 } );
			}
			
			if (_showVehicles)
			{
				for each (var v:VehicleIcon in _vehicles)
					TweenLite.to(v, 1, { alpha:1 } );
			} else {
				for each (v in _vehicles)
					TweenLite.to(v, 1, { alpha:0 } );
			}
			
			if (_showPlayers)
			{
				for each (var p:PlayerIcon in _players)
					TweenLite.to(p, 1, { alpha:1 } );
			} else {
				for each (p in _players)
					TweenLite.to(p, 1, { alpha:0 } );
			}
		}
		
		private function addButton(callback:Function, x:Number, y:Number, bitmap:Bitmap):void 
		{
			var s:Sprite = new Sprite();
			s.x = x;
			s.y = y;
			
			s.addEventListener(MouseEvent.CLICK, callback);
			s.addChild(bitmap);
			s.buttonMode = true;
			
			addChild(s);
		}
		
		private function mapConfigLoaded(e:Event):void 
		{
			// read out map data
			var lines:Array = e.target.data.split(/\n/);
			
			IMAGE_WIDTH = lines[1];
			IMAGE_HEIGHT = lines[2];
			OFFSET_X = lines[3];
			OFFSET_Y = lines[4];
			SCALE_X = lines[5];
			SCALE_Y = lines[6];
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, mapLoaded);
			loader.load(new URLRequest(lines[0]));
			_loadingTF.text = "Loading map graphic \""+lines[0]+"\"...";
		}
		
		private function mapLoaded(e:Event):void 
		{
			var derp:SharedObject = SharedObject.getLocal("mapPos");
			if (derp.data.mapX != null)
				_map.x = derp.data.mapX;
			if (derp.data.mapY != null)
				_map.y = derp.data.mapY;
			if (derp.data.mapScale != null)
			{
				_map.scaleX = derp.data.mapScale;
				_map.scaleY = derp.data.mapScale;
			}
				
			_loadingTF.text = "Load complete.";
			_map.addChild(e.target.content as Bitmap);
			
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
			derp.data.mapScale = _map.scaleX;
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
		
		public static function str2bool(str:String):Boolean
		{
			if (str.toLowerCase() == "true")
				return true;
			return false;
		}
		
		private function xmlLoaded(e:Event):void 
		{
			_loadingTF.text = "";
			Logging.getLogger(Main).error("I got something");
			
			var xml:XML = new XML(e.target.data);
			
			_icons = str2bool(xml.icons);
			
			//Logging.getLogger(Main).info(xml);
			
			for each (var player:XML in xml.player)
			{
				// search for icon with the same id
				var found:Boolean = false;
				var id:String = String(player.id);
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
			
			for each (var vehicle:XML in xml.vehicle)
			{
				// search for icon with the same id
				found = false;
				var nid:int = vehicle.id;				
				for each (var vehicl:VehicleIcon in _vehicles)
				{
					if (vehicl.id == nid)
					{
						found = true;
						
						// update data
						vehicl.newData(vehicle);
					}
				}
				
				// if we didnt find one, add icon to list and as a child
				if (!found)
				{
					vehicl = new VehicleIcon(vehicle);
					vehicl.mouseChildren = false;
					_map.addChild(vehicl);
					_vehicles.push(vehicl);
				}
			}
			
			for each (var deployable:XML in xml.deployable)
			{
				// search for icon with the same id
				found = false;
				nid = deployable.id;				
				for each (var deployabl:DeployableIcon in _deployables)
				{
					if (deployabl.id == nid)
					{
						found = true;
						
						// update data
						deployabl.newData(deployable);
					}
				}
				
				// if we didnt find one, add icon to list and as a child
				if (!found)
				{
					deployabl = new DeployableIcon(deployable);
					deployabl.mouseChildren = false;
					_map.addChild(deployabl);
					_deployables.push(deployabl);
				}
			}
		}
		
		public function get map():Sprite 
		{
			return _map;
		}
		
		public function get icons():Boolean 
		{
			return _icons;
		}
		
		public static function convertCoords(x:Number, y:Number):Point
		{
			x += OFFSET_X;
			y += OFFSET_Y;
			
			x = x / SCALE_X * Main.IMAGE_WIDTH;
			y = y / SCALE_Y * Main.IMAGE_HEIGHT;
				
			return new Point(Math.floor(x), Math.floor(y));
		}
		
	}
	
}
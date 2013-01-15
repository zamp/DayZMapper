package  
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	/**
	 * ...
	 * @author zamp
	 */
	public class Settings 
	{
		static public var instance:Settings;
		static public var noPlayerIcons:Boolean = true;
		
		public function Settings() 
		{
			if (instance == null)
				instance = this;
			else
				throw new Error("Settings instantiated twice!");
				
			var loader:URLLoader = new URLLoader(new URLRequest("settings.xml"));
			loader.addEventListener(Event.COMPLETE, loaded);
		}
		
		private function loaded(e:Event):void 
		{
			var xml:XML = e.target.data as XML;
			
			noPlayerIcons = Boolean(xml.noPlayerIcons);
		}
		
	}

}
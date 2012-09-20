package  
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Ville Nousiainen
	 */
	final public class ColorUtil 
	{
		
		public function ColorUtil() 
		{
			
		}
		
		public static function interpolateColor(fromColor:uint, toColor:uint, progress:Number, limit:Boolean = false):uint
		{
			if (limit)
			{
				progress = progress < 0 ? 0 : progress;
				progress = progress > 1 ? 1 : progress;
			}
			var q:Number = 1-progress;
			var fromA:uint = (fromColor >> 24) & 0xFF;
			var fromR:uint = (fromColor >> 16) & 0xFF;
			var fromG:uint = (fromColor >>  8) & 0xFF;
			var fromB:uint =  fromColor        & 0xFF;
			var toA:uint = (toColor >> 24) & 0xFF;
			var toR:uint = (toColor >> 16) & 0xFF;
			var toG:uint = (toColor >>  8) & 0xFF;
			var toB:uint =  toColor        & 0xFF;
			var resultA:uint = fromA*q + toA*progress;
			var resultR:uint = fromR*q + toR*progress;
			var resultG:uint = fromG*q + toG*progress;
			var resultB:uint = fromB*q + toB*progress;
			var resultColor:uint = resultA << 24 | resultR << 16 | resultG << 8 | resultB;
			return resultColor;
		}
		
		public static function setAlpha(color:uint, alpha:Number):uint
		{
			var a:uint = alpha * 256;
			var r:uint = (color >> 16) & 0xFF;
			var g:uint = (color >>  8) & 0xFF;
			var b:uint =  color        & 0xFF;
			return (a << 24 | r << 16 | g << 8 | b);
		}
		
		public static function addColorNoAlpha(color:uint, color2:uint, multiplier:Number = 1):uint
		{
			var r:uint = ((color >> 16) & 0xFF);
			var g:uint = ((color >> 8) & 0xFF);
			var b:uint = color & 0xFF;
			
			var r2:uint = ((color2 >> 16) & 0xFF);
			var g2:uint = ((color2 >> 8) & 0xFF);
			var b2:uint = color2 & 0xFF;
			
			r += (r2 * multiplier);
			g += (g2 * multiplier);
			b += (b2 * multiplier);
				
			return (r << 16 | g << 8 | b);
		}
		
		public static function addColor(color:uint, color2:uint, multiplier:Number = 1):uint
		{
			var a:uint = ((color >> 24) & 0xFF);
			var r:uint = ((color >> 16) & 0xFF);
			var g:uint = ((color >> 8) & 0xFF);
			var b:uint = color & 0xFF;
			
			var a2:uint = ((color2 >> 24) & 0xFF);
			var r2:uint = ((color2 >> 16) & 0xFF);
			var g2:uint = ((color2 >> 8) & 0xFF);
			var b2:uint = color2 & 0xFF;
			
			a += (a2 * multiplier);
			r += (r2 * multiplier);
			g += (g2 * multiplier);
			b += (b2 * multiplier);
				
			return (a << 24 | r << 16 | g << 8 | b);
		}
		
		/**
		 * Return a gradient given a color.
		 *
		 * @param color      Base color of the gradient.
		 * @param intensity  Amount to shift secondary color.
		 * @return An array with a length of two colors.
		 */
		public static function makeGradient(color:uint, intensity:int = 20):Array
		{
			var c:Color = hexToRGB(color);
			for (var key:String in c)
			{
				c[key] += intensity;
				c[key] = Math.min(c[key], 255); // -- make sure below 255
				c[key] = Math.max(c[key], 0);   // -- make sure above 0
			}
			return [color, RGBToHex(c)];
		}

		/**
		 * Convert a uint (0x000000) to a color object.
		 *
		 * @param hex  Color.
		 * @return Converted object {r:, g:, b:}
		 */
		public static function hexToRGB(hex:uint):Color
		{
			var c:Color = new Color();

			c.a = hex >> 24 & 0xFF;
			c.r = hex >> 16 & 0xFF;
			c.g = hex >> 8 & 0xFF;
			c.b = hex & 0xFF;

			return c;
		}
		
		public static function grayscale(hex:uint):Number
		{
			var c:Color = hexToRGB(hex);
			return (0.299 * c.r) + (0.587 * c.g) + (0.114 * c.b);
		}		

		/**
		 * Convert a color object to uint octal (0x000000).
		 *
		 * @param c  Color object {r:, g:, b:, a:}.
		 * @return Converted color uint (0x000000).
		 */
		public static function RGBToHex(c:Color):uint
		{
			return uint(c.r | (c.g << 8) | (c.b << 16) | (c.a << 24));
		}
		
		public static function average(source:BitmapData, rect:Rectangle = null):uint
		{
			if (rect == null)
				rect = source.rect;
			var histogram:Vector.<Vector.<Number>> = source.histogram(rect);
 
			var red:Number = 0;
			var green:Number = 0;
			var blue:Number = 0;
			 
			var w:Number = rect.width;
			var h:Number = rect.height;
			var countInverse:Number = 1 / (w*h);
			 
			for (var i:int = 0; i < 256; ++i) {
				red += i * histogram[0][i];
				green += i * histogram[1][i];
				blue += i * histogram[2][i];
			}
			 
			red *= countInverse;
			green *= countInverse;
			blue *= countInverse;
			 
			return (red << 16) | (green << 8) | blue;
		}
	}

}
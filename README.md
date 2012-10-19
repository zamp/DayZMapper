<b>How to install:</b>

<pre>
1. Copy bin/* to your webhost (Can be the server that DayZ is running on but you
will need either apache or some other http server that can handle php)
2. Rename example_config.php to config.php
3. Change config.php to have your username/password/hostname etc.
4. Rename one of the map_MAPNAME_example.txt to map.txt (chernarus for chernarus, etc.) 
Thanks to Falcon911 for takistan map
5. Point your browser to wherever you copied stuff to.
</pre>

<b>TODO:</b>
<pre>
- Icons in the upper left corner to toggle player/vehicle/tent visibility
- Toggleable position bounding (won't show out of map data)
</pre>

<b>Optional Stuff:</b>

Create .htaccess file to password protect the website.

If you want to use your own map graphic you need to specify certain values in the map.txt

Here is an example map.txt with comments (Do not add comments in the map.txt otherwise it will not work!)
<pre>
map_chernarus.jpg // the map file that is loaded.
1234 // how wide the image is
4321 // how tall the image is
100 // X offset of the image. 0 coordinate is 100 meters away from the left edge
30 // Y offset of the image. 0 coordinate is 30 meters away from the bottom edge
1000 // map X scale. how many meters are on the map X axis
1000 // map Y scale. how many meters are on the map Y axis
</pre>

If you have any questions ask zamp @ freenode/ircnet/quakenet/whatever just whois me.
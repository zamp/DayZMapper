<b>How to install:</b>

<pre>
1. Copy bin/* to your webhost (Can be the server that DayZ is running on but you
will need either apache or some other http server that can handle php)
2. Rename example_config.php to config.php
3. Change config.php to have your username/password/hostname etc.
4. Rename one of the map_MAPNAME_example.txt to map.txt (chernarus for chernarus, etc.) 
Thanks to ihatetn931 for takistan map
5. Point your browser to wherever you copied stuff to.
</pre>

<b>Optional:</b>

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

<b>Cheat (teleportation) prevention the awesome way:</b>
<pre>
Add this database to your dayz database:

CREATE TABLE IF NOT EXISTS `survivor_last_pos` (
  `id` int(8) unsigned NOT NULL,
  `pos` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

Copy dayzmapper/cheatchecker.php to the install location and run this 
in cron (every minute) to alert you of any hackers.
It will print out people who have moved more than 2 kilometers in a 
minute. Usually this lets you see cheaters fairly quickly and you 
don't have to have the mapper open all of the time. Sometimes you get 
faulty readings if people use a vehicle, will fix later.
You can append the output in cron with "php cheatchecker.php >> FILE_NAME_HERE"
Then you can tail that file and play an alert sound of your choice 
whenever a new line is added to the file
"tail -f FILE_NAME_HERE | while read line ; do aplay -q alert.wav 2>&1 1>/dev/null ; echo $line ; done"
Make sure to provide the alert.wav to be played!
</pre>

<b>Vehicle reset</b>
<pre>
Copy dayzmapper/vehiclereset.php to install directory and run it in 
cron or when you restart the server.
It will reset objects to their spawn locations (removes wires, sandbags 
and tank traps) in 3, 5, and 7 day intervals. Tents are of course unaffected.
</pre>

If you have any questions ask zamp @ freenode/ircnet/quakenet/whatever just whois me.
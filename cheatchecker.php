<?php
/***
TO USE THIS YOU NEED TO ADD THIS TABLE TO YOUR DAYZ DATABASE!!!

CREATE TABLE IF NOT EXISTS `survivor_last_pos` (
  `id` int(8) unsigned NOT NULL,
  `pos` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

*/
header("Content-Type: text/plain");
// added to maybe fix cache blowing up to insane size
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past

include("config.php");

mysql_connect($host, $user, $password) or die ("Unable to connect");
@mysql_select_db($database) or die ("Unable to select DB");

$result = mysql_query("SELECT * FROM survivor WHERE last_update > DATE_SUB(now(), INTERVAL 5 MINUTE) AND is_dead=0");
if ($result)
{
	while ($row = mysql_fetch_array($result))
	{
		$position = $row["pos"];
		$pos = str_replace(array("[","]"), "", $position);
		$posArray = explode(",", $pos);

		$x = $posArray[1];
		$y = $posArray[2];
		
		$id = $row["unique_id"];
		$result2 = mysql_query("SELECT name FROM profile WHERE unique_id=$id");
		$name = "Unnamed";
		if ($result2)
		{
			$row2 = mysql_fetch_array($result2);
			$name = $row2["name"];
		}
		
		$id = $row["id"];
		$result2 = mysql_query("SELECT pos FROM survivor_last_pos WHERE id='$id'");
		if ($result2)
		{
			$row2 = mysql_fetch_array($result2);
			if ($row2)
			{
				$pos = $row2["pos"];
				$pos = str_replace(array("[","]"), "", $pos);
				$posArray = explode(",", $pos);
				
				$x2 = (float)$posArray[1];
				$y2 = (float)$posArray[2];
				
				// distance
				$x3 = ($x - $x2) * ($x - $x2);
				$y3 = ($y - $y2) * ($y - $y2);
				$distance = sqrt($x3 + $y3);
				
				if ($distance > 2000 && $x2 != 0 && $y2 != 0) // moved more than 2 kliks in a minute. impossible unless in chopper, usually cheater
					echo "$name distance moved: $distance from $x2,$y2 to $x,$y\n";
				
				// update pos
				mysql_query("UPDATE survivor_last_pos SET pos='$position' WHERE id='$id' LIMIT 1");
			} else {
				//echo "$name has no last pos\n";
				$pos = $row["pos"];
				// no position in database, create new
				mysql_query("INSERT INTO survivor_last_pos VALUES ('$id','$position')");
			}
		}
	}
}

mysql_close();
?>

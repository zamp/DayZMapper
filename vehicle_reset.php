<?php
header("Content-Type: text/plain");

include("config.php");

mysql_connect($host, $user, $password) or die ("Unable to connect");
@mysql_select_db($database) or die ("Unable to select DB");

$result = mysql_query("SELECT * FROM objects");
if ($result)
{
	while ($row = mysql_fetch_array($result))
	{
		$pos = $row[pos];
		$pos = str_replace(array("[","]"), "", $pos);
		$posArray = explode(",", $pos);
		
		$otype = $row[otype];
		$id = $row[id];		
		$age = strtotime("now") - strtotime($row[lastupdate]);
		$uid = $row[uid];

		$x = $posArray[1];
		$y = $posArray[2];
		
		$y = $y - 15365;
		$y *= -1;
		
		echo $row[otype]."\n";
		if ($x < 0 || $x > 150000 || $y < 0 || $y > 150000)
		{
			echo "\tout of bounds\n";
		}
		
		switch ($otype)
		{
			case "Wire_cat1":
				// 259200 3 days
				if ($age > 259200)
				{
					echo "\tolder than 3 days. Removing from database\n";					
					mysql_query("DELETE FROM objects WHERE id='$id'");
				}
			break;
			case "Hedgehog_DZ":
			case "Sandbag1_DZ":
				// 432000 5 days
				if ($age > 432000)
				{
					echo "\tolder than 5 days. Removing from database\n";
					mysql_query("DELETE FROM objects WHERE id='$id'");
				}
			break;
			default:
				// 604800 7 days (week)
				if ($age > 604800 && $otype != "TentStorage")
				{
					echo "\tolder than 7 days. Moving to spawn\n";
					$result2 = mysql_query("SELECT pos FROM spawns WHERE uuid='$uid' LIMIT 1");
					if ($result2)
					{
						$row2 = mysql_fetch_array($result2);
						$pos = $row2[pos];
						$ownPos = $row[pos];
						
						if ($pos == $ownPos)
							echo "\tAt spawn already\n";
						else
							mysql_query("UPDATE objects SET pos='$pos' WHERE id='$id' LIMIT 1");
					} else {
						echo "\tCan't find spawn?\n";
					}
				}
			break;
		}
	}
}

mysql_close();
?>

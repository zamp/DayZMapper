<?php
error_reporting(0);

header("Content-Type: text/plain");
// added to maybe fix cache blowing up to insane size
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past

include("config.php");

?><stuff>
<?php

mysql_connect($host, $user, $password) or die ("Unable to connect");
@mysql_select_db($database) or die ("Unable to select DB");

$result = mysql_query("SELECT * FROM survivor WHERE last_update > DATE_SUB(now(), INTERVAL 5 MINUTE) AND is_dead=0");
if ($result)
{
	while ($row = mysql_fetch_array($result))
	{
		$pos = $row["pos"];
		$pos = str_replace(array("[","]"), "", $pos);
		$posArray = explode(",", $pos);

		$x = $posArray[1];
		$y = $posArray[2];
		
		$y = $y - 15365;
		$y *= -1;
		
		$id = $row["unique_id"];
		$result2 = mysql_query("SELECT name,humanity FROM profile WHERE unique_id=$id");
		$name = "Unnamed";
		$humanity = 0;
		if ($result2)
		{
			$row2 = mysql_fetch_array($result2);
			$name = $row2["name"];
			$humanity = $row2["humanity"];
		}
		
?>	<player>
		<id><?=$row[id]?></id>
		<name><![CDATA[<?=$name?>]]></name>
		<x><?=$x?></x>
		<y><?=$y?></y>
		<age><?=strtotime($row["last_update"]) - strtotime("now")?></age>
		<humanity><?=$humanity?></humanity>
		<inventory><![CDATA[<?=$row["inventory"]?>]]></inventory>
		<model><![CDATA[<?=$row["model"]?>]]></model>
		<hkills><?=$row["survivor_kills"]?></hkills>
		<bkills><?=$row["bandit_kills"]?></bkills>
	</player>
<?php
	}
}

$result = mysql_query("SELECT * FROM objects WHERE instance='$instance'");
if ($result)
{
	while ($row = mysql_fetch_array($result))
	{
		$pos = $row[pos];
		$pos = str_replace(array("[","]"), "", $pos);
		$posArray = explode(",", $pos);

		$x = $posArray[1];
		$y = $posArray[2];
		
		$y = $y - 15365;
		$y *= -1;
		
?>	<object>
		<id><?=$row[id]?></id>
		<otype><![CDATA[<?=$row["otype"]?>]]></otype>
		<x><?=$x?></x>
		<y><?=$y?></y>
		<age><?=strtotime($row["last_update"]) - strtotime("now")?></age>
		<inventory><![CDATA[<?=$row["inventory"]?>]]></inventory>
	</object>
<?php
	}
}

?></stuff><?php

mysql_close();
?>

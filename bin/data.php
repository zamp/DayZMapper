<?php
header("Content-Type: text/plain");

$user = "dayz";
$password = "ultimatesupersecret126";
$database = "dayz_lingor";
$host = "127.0.0.1:3306";

?><stuff>
<?php

mysql_connect($host, $user, $password) or die ("Unable to connect");
@mysql_select_db($database) or die ("Unable to select DB");

$result = mysql_query("SELECT * FROM survivor WHERE last_update > DATE_SUB(now(), INTERVAL 5 MINUTE) AND is_dead=0");
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
		
		$id = $row[unique_id];
		$result2 = mysql_query("SELECT name FROM profile WHERE unique_id=$id");
		$name = "Unnamed";
		if ($result2)
		{
			$row2 = mysql_fetch_array($result2);
			$name = $row2[name];
		}
		
?>	<player>
		<id><?=$row[id]?></id>
		<name><![CDATA[<?=$name?>]]></name>
		<x><?=$x?></x>
		<y><?=$y?></y>
		<age><?=strtotime($row[lastupdate]) - strtotime("now")?></age>
		<humanity><?=$row[humanity]?></humanity>
		<inventory><![CDATA[<?=$row[inventory]?>]]></inventory>
		<model><![CDATA[<?=$row[model]?>]]></model>
		<hkills><?=$row[survivor_kills]?></hkills>
		<bkills><?=$row[bandit_kills]?></bkills>
	</player>
<?php
	}
}

$result = mysql_query("SELECT * FROM objects");
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
		<otype><![CDATA[<?=$row[otype]?>]]></otype>
		<x><?=$x?></x>
		<y><?=$y?></y>
		<age><?=strtotime($row[lastupdate]) - strtotime("now")?></age>
		<inventory><![CDATA[<?=$row[inventory]?>]]></inventory>
	</object>
<?php
	}
}

?></stuff><?php

mysql_close();
?>

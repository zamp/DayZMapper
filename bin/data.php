<?php
// works with schema 0.22
error_reporting(0);

header("Content-Type: text/plain");
// added to maybe fix cache blowing up to insane size
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past

include("config.php");
include("Database.php");

?><stuff>
<?php

$db = new Database($db_host, $db_user, $db_password, $db_database);

$db->connect();

$db->query("SELECT * FROM survivor WHERE last_updated > DATE_SUB(now(), INTERVAL 5 MINUTE) AND is_dead=0");
while ($row = $db->fetch())
{
	$pos = $row["worldspace"];
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
			<age><?=strtotime($row["last_updated"]) - strtotime("now")?></age>
			<humanity><?=$humanity?></humanity>
			<inventory><![CDATA[<?=$row["inventory"]?>]]></inventory>
			<model><![CDATA[<?=$row["model"]?>]]></model>
			<hkills><?=$row["survivor_kills"]?></hkills>
			<bkills><?=$row["bandit_kills"]?></bkills>
		</player>
	<?php
}

$db->query(
	"SELECT vehicle.id, vehicle.class_name, vehicle.inventory, instance_vehicle.worldspace, instance_vehicle.last_updated 
	FROM instance_vehicle
	INNER JOIN vehicle ON vehicle.id = instance_vehicle.vehicle_id");
while ($row = $db->fetch())
{
	$pos = $row["worldspace"];
	$pos = str_replace(array("[","]"), "", $pos);
	$posArray = explode(",", $pos);

	$x = $posArray[1];
	$y = $posArray[2];
	
	$y = $y - 15365;
	$y *= -1;
	
	?>	<vehicle>
			<id><?=$row["id"]?></id>
			<otype><![CDATA[<?=$row["class_name"]?>]]></otype>
			<x><?=$x?></x>
			<y><?=$y?></y>
			<age><?=strtotime($row["last_updated"]) - strtotime("now")?></age>
			<inventory><![CDATA[<?=$row["inventory"]?>]]></inventory>
		</vehicle>
	<?php
}

$db->query(
	"SELECT instance_deployable.id, instance_deployable.worldspace, instance_deployable.inventory, instance_deployable.last_updated, deployable.class_name 
	FROM instance_deployable
	INNER JOIN deployable ON deployable.id = instance_deployable.deployable_id");
while ($row = $db->fetch())
{
	$pos = $row["worldspace"];
	$pos = str_replace(array("[","]"), "", $pos);
	$posArray = explode(",", $pos);

	$x = $posArray[1];
	$y = $posArray[2];
	
	$y = $y - 15365;
	$y *= -1;
	
	?>	<deployable>
			<id><?=$row["id"]?></id>
			<otype><![CDATA[<?=$row["class_name"]?>]]></otype>
			<x><?=$x?></x>
			<y><?=$y?></y>
			<age><?=strtotime($row["last_updated"]) - strtotime("now")?></age>
			<inventory><![CDATA[<?=$row["inventory"]?>]]></inventory>
		</deployable>
	<?php
}
?></stuff><?php

$db->close();
?>

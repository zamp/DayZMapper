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

//$db->query("SELECT * FROM survivor WHERE last_updated > DATE_SUB(now(), INTERVAL 5 MINUTE) AND is_dead=0");
$db->query(
	"SELECT survivor.id, survivor.model, survivor.state, survivor.worldspace, survivor.survivor_kills,survivor.bandit_kills, survivor.inventory,
	profile.name, profile.humanity, profile.total_survivor_kills, profile.total_bandit_kills
	FROM survivor
	INNER JOIN profile ON profile.unique_id = survivor.unique_id
	WHERE survivor.last_updated > DATE_SUB(now(), INTERVAL 5 MINUTE) AND survivor.is_dead=0");
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
	$age = strtotime($row["last_updated"]) - strtotime("now");
	$name = $row["name"];
	$humanity = $row["humanity"];
	$inventory = $row["inventory"];
	$model = $row["model"];
	$survivor_kills = $row["survivor_kills"] . " (" . $row["total_survivor_kills"] . ")";
	$bandit_kills = $row["bandit_kills"] . " (" . $row["total_bandit_kills"] . ")";
	
	?>	<player>
			<id><?php echo $row[id]?></id>
			<name><![CDATA[<?php echo $name?>]]></name>
			<x><?php echo $x?></x>
			<y><?php echo $y?></y>
			<age><?php echo $age?></age>
			<humanity><?php echo $humanity?></humanity>
			<inventory><![CDATA[<?php echo $inventory?>]]></inventory>
			<model><![CDATA[<?php echo $model?>]]></model>
			<hkills><![CDATA[<?php echo $survivor_kills?>]]></hkills>
			<bkills><![CDATA[<?php echo $bandit_kills?>]]></bkills>
		</player>
	<?php
}

$db->query(
	"SELECT instance_vehicle.id, vehicle.class_name, vehicle.inventory, instance_vehicle.worldspace, instance_vehicle.last_updated 
	FROM instance_vehicle
	LEFT JOIN vehicle ON vehicle.id = instance_vehicle.vehicle_id");
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
			<id><?php echo $row["id"]?></id>
			<otype><![CDATA[<?php echo $row["class_name"]?>]]></otype>
			<x><?php echo $x?></x>
			<y><?php echo $y?></y>
			<age><?php echo strtotime($row["last_updated"]) - strtotime("now")?></age>
			<inventory><![CDATA[<?php echo $row["inventory"]?>]]></inventory>
		</vehicle>
	<?php
}

$db->query(
	"SELECT instance_deployable.id, instance_deployable.worldspace, instance_deployable.inventory, instance_deployable.last_updated, deployable.class_name 
	FROM instance_deployable
	LEFT JOIN deployable ON deployable.id = instance_deployable.deployable_id");
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
			<id><?php echo $row["id"]?></id>
			<otype><![CDATA[<?php echo $row["class_name"]?>]]></otype>
			<x><?php echo $x?></x>
			<y><?php echo $y?></y>
			<age><?php echo strtotime($row["last_updated"]) - strtotime("now")?></age>
			<inventory><![CDATA[<?php echo $row["inventory"]?>]]></inventory>
		</deployable>
	<?php
}
?></stuff><?php

$db->close();
?>

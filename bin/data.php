<?php
// works with schema 0.27
error_reporting(0);

header("Content-Type: text/plain");
// added to maybe fix cache blowing up to insane size
header("Cache-Control: no-cache, must-revalidate"); // HTTP/1.1
header("Expires: Sat, 26 Jul 1997 05:00:00 GMT"); // Date in the past

include("config.php");
include("Database.php");

echo '<stuff>' . "\n";

$db = new Database($db_host, $db_user, $db_password, $db_database);

$db->connect();

$db->query("SELECT
	s.id,
	s.model,
	s.state,
	s.worldspace,
	s.inventory,
	p.name,
	p.humanity,
	concat(s.survivor_kills, ' (', p.total_survivor_kills, ')') survivor_kills,
	concat(s.bandit_kills, ' (', p.total_bandit_kills, ')') bandit_kills
FROM
	survivor s
INNER JOIN
	profile p on p.unique_id = s.unique_id
WHERE
	s.last_updated > DATE_SUB(now(), INTERVAL 5 MINUTE)
AND
	s.is_dead = 0
");

while($row = $db->fetch())
{
	$posArray = json_decode($row["worldspace"]);
	
	$row['x'] = $posArray[1][0];
	$row['y'] = -($posArray[1][1]-15365);
	
	$player['id'] = $row["id"];
	$player['x'] = $row['x'];
	$player['y'] = $row['y'];
	$player['age'] = strtotime($row["last_updated"]) - time();
	$player['name'] = $row["name"];
	$player['humanity'] = $row["humanity"];
	$player['inventory'] = $row["inventory"];
	$player['model'] = $row["model"];
	$player['survivor_kills'] = $row["survivor_kills"];
	$player['bandit_kills'] = $row["bandit_kills"];
	
	echo "\t" . '<player>' . "\n";
	foreach($player as $k => $v)
	{
		echo "\t\t" . '<' . $k . '><![CDATA[' . $v . ']]></' . $k . '>' . "\n";
	}
	echo "\t" . '</player>' . "\n";
}

$db->query("SELECT
	iv.id as id,
	iv.worldspace,
	v.class_name otype,
	iv.inventory,
	iv.last_updated
FROM
	instance_vehicle iv
JOIN
	world_vehicle wv on iv.world_vehicle_id = wv.id
JOIN
	vehicle v on wv.vehicle_id = v.id
");

while($row = $db->fetch())
{
	$posArray = json_decode($row["worldspace"]);
	
	$row['x'] = $posArray[1][0];
	$row['y'] = -($posArray[1][1]-15365);
	
	$row['age'] = strtotime($row["last_updated"]) - date();
	
	echo "\t" . '<vehicle>' . "\n";
	foreach($row as $k => $v)
	{
		echo "\t\t" . '<' . $k . '><![CDATA[' . $v . ']]></' . $k . '>' . "\n";
	}
	echo "\t" . '</vehicle>' . "\n";
}

$db->query("SELECT
	id.id,
	id.worldspace,
	id.inventory,
	id.last_updated,
	d.class_name otype 
FROM
	instance_deployable id
JOIN
	deployable d on	d.id = id.deployable_id
");

while($row = $db->fetch())
{
	$posArray = json_decode($row["worldspace"]);
	
	$row['x'] = $posArray[1][0];
	$row['y'] = -($posArray[1][1]-15365);
	
	echo "\t" . '<deployable>';
	foreach($row as $k => $v)
	{
		echo "\t\t" . '<' . $k . '><![CDATA[' . $v . ']]></' . $k . '>' . "\n";
	}
	echo "\t" . '</deployable>' . "\n";
}

echo '</stuff>' . "\n";

$db->close();
?>
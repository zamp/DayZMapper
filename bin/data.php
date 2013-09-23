<?php
// Works with schema 0.36
error_reporting(0);

header('Content-Type: text/plain');
// Avoid browser caching
header('Cache-Control: no-cache, must-revalidate');
header('Expires: Sat, 26 Jul 1997 05:00:00 GMT');

include('config.php');

try {
	$db = new PDO('mysql:host='.$db['host'].';port='.$db['port'].';dbname='.$db['database'], $db['user'], $db['password']);
} catch(PDOException $e) {
	die($e -> getMessage());
}

echo '<stuff>' . "\n";
echo "\t<icons>".($config['icons']?"true":"false")."</icons>\n";

// Fetch players
$query = $db->prepare("SELECT
	s.id,
	s.model,
	s.state,
	s.worldspace,
	s.inventory,
	p.name,
	p.humanity,
	s.last_updated,
	concat(s.survivor_kills, ' (', p.total_survivor_kills, ')') hkills,
	concat(s.bandit_kills, ' (', p.total_bandit_kills, ')') bkills
FROM
	survivor s
INNER JOIN
	profile p on p.unique_id = s.unique_id
WHERE
	s.last_updated > DATE_SUB(now(), INTERVAL 5 MINUTE)
AND
	s.is_dead = 0");

$query->execute(array($config['instance']));
$rows = $query->fetchAll(PDO::FETCH_ASSOC);

foreach($rows as $row)
{
	$posArray = json_decode($row['worldspace']);
	
	$row['x'] = $posArray[1][0];
	$row['y'] = -($posArray[1][1]-15365);
	
	$row['age'] = strtotime($row['last_updated']) - time();
	$row['name'] = htmlspecialchars($row['name']);
	
	echo "\t" . '<player>' . "\n";
	foreach($row as $k => $v)
	{
		echo "\t\t" . '<' . $k . '><![CDATA[' . $v . ']]></' . $k . '>' . "\n";
	}
	echo "\t" . '</player>' . "\n";
}

// Fetch vehicles
$query = $db->prepare("SELECT
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
WHERE
	iv.instance_id = ?");

$query->execute(array($config['instance']));
$rows = $query->fetchAll(PDO::FETCH_ASSOC);

foreach($rows as $row)
{
	$posArray = json_decode($row["worldspace"]);
	
	$row['x'] = $posArray[1][0];
	$row['y'] = -($posArray[1][1]-15365);
	
	$row['age'] = strtotime($row['last_updated']) - time();
	
	echo "\t" . '<vehicle>' . "\n";
	foreach($row as $k => $v)
	{
		echo "\t\t" . '<' . $k . '><![CDATA[' . $v . ']]></' . $k . '>' . "\n";
	}
	echo "\t" . '</vehicle>' . "\n";
}

// Fetch deployables
$query = $db->prepare("SELECT
	id.id,
	id.worldspace,
	d.class_name otype,
	id.inventory,
	id.last_updated
FROM
	instance_deployable id
JOIN
	deployable d on	d.id = id.deployable_id
WHERE
	id.instance_id = ?");

$query->execute(array($config['instance']));
$rows = $query->fetchAll(PDO::FETCH_ASSOC);

foreach($rows as $row)
{
	$posArray = json_decode($row['worldspace']);
	
	$row['x'] = $posArray[1][0];
	$row['y'] = -($posArray[1][1]-15365);
	
	echo "\t" . '<deployable>' . "\n";
	foreach($row as $k => $v)
	{
		echo "\t\t" . '<' . $k . '><![CDATA[' . $v . ']]></' . $k . '>' . "\n";
	}
	echo "\t" . '</deployable>' . "\n";
}

echo '</stuff>' . "\n";

?>
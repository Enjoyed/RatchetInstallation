<?php
$connecting_as = $_SERVER['REMOTE_ADDR'];
$accepted = array(
	"::1",
	"127.0.0.1",
	"192.168.1.102",
	"10.19.250.20",
	"10.19.250.30",
	"10.19.250.40",
	"10.19.250.50"
);
if(in_array($connecting_as, $accepted))
{
	if(count($_GET))
	{
		$query = $_SERVER['QUERY_STRING'];
		$send = explode('&', $query);
		$command = "nodejs /opt/websocket/updater.js ";
		foreach($send as $valor){
			$command .= "$valor ";
		}
		exec($command);
	}
}
else
{
	echo "YOU DONT HAVE PERMISSIONS TO ACCESS THIS PAGE.";
}
?>

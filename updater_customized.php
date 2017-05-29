<?php
//
// NOTE: This is a trust=yes web, any query will affect the whole system.
// DONT DO IT MANUALLY. Only thinked to process Arduino queries.
//
// Get the IP of the client connecting
$connecting_as = $_SERVER['REMOTE_ADDR'];
// List of accepted IPs
$accepted = array(
	"::1",
	"127.0.0.1",
	"10.19.250.100",
	"10.19.250.110",
	"10.19.250.120",
	"10.19.250.130"
);
// Check if it is valid
if(in_array($connecting_as, $accepted))
{
	// Check if there are GET requests
	if(count($_GET))
	{
		// Get GET request
		$query = $_SERVER['QUERY_STRING'];
		// Divide it in small piecessss
		$send = explode('&', $query);
		// Default command (to update)
		$command = "nodejs /opt/websocket/updater.js ";
		// Foreach query value
		foreach($send as $valor){
			// Add it to the command as a parameter
			$command .= "$valor ";
		}
		// Run it in the shell!
		exec($command);
	}
}
// Non accepted visitors
else
{
	// Say we dont want annoying access.
	echo "YOU DONT HAVE PERMISSIONS TO ACCESS THIS PAGE.";
}
?>

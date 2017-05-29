<?php
namespace WebSocketGerard;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
// Initialize every sensor/actuator we have.
// SYNTAX: <device_id>_<sensor_id>
$GLOBALS["values"] = array(
/* Dispositiu d1 */
	"d1_led1" => 0,
/* Dispositiu d2 */
	"d2_led1" => 0,
/* Dispositiu d3 */
	"d2_led1" => 0,
/* Dispositiu R1 */
	"r1_r1" => 0,
	"r1_r2" => 0,
	"r1_r3" => 0,
	"r1_r4" => 0,
	"r1_r5" => 0,
	"r1_r6" => 0,
	"r1_r7" => 0,
	"r1_r8" => 0);
// Set our IP for each device
$GLOBALS["dispositius"] = array(
"r1" => "10.19.250.100", /* IP r1 */ 
"d1" => "10.19.250.110", /* IP d1 */
"d2" => "10.19.250.120", /* IP d2 */
"d3" => "10.19.250.130"  /* IP d3 */
);


// Simple function to check if a string is JSON
function isJson($string) {
	json_decode($string);
	return (json_last_error() == JSON_ERROR_NONE);
}
// Our Class, here happens the magic
class Chat implements MessageComponentInterface {
	// Here we store each connection.
	protected $clients;
	// A simple construct
	public function __construct() {
		$this->clients = new \SplObjectStorage;
	}
	// What happens when a client opens a connection?
	public function onOpen(ConnectionInterface $conn) {
		// We add it to the list.
		$this->clients->attach($conn);
		// Encode our array with ALL sensors/actuators
		$send = json_encode($GLOBALS["values"]);
		// And send it to the new client connected.
		foreach ($this->clients as $client) {
			if ($conn == $client) {
				$client->send($send);
			}
		}
		// A simple echo to debug
		echo "New connection! ({$conn->resourceId})\n";
	}
	// What happens when a client send us a message?
	public function onMessage(ConnectionInterface $conn, $msg) {
		// Lets count to how many will send the message, because why not?
		$numRecv = count($this->clients) - 1;
		// I only accept JSON messages, to evade some problems.
		if(isJson($msg)) 
		{
			// Echo to how many will send new values.
			echo sprintf("Updating values to %d client%s" . "\n"
			,$numRecv, $numRecv == 1 ? "" : "s");
			// Lets process the incoming message
			$array = json_decode($msg,true);
			// If the message comes from the web client
			if(!isset($array["incoming"]) and !isset($array["refresh"]))
			{
				// For each value sended (99,99999% cases will be only 1.)
				foreach($array as $sensor => $valor) {
					// Who is the father (ip of device of the sensor/actuator)
					$sendValor = explode("_",$sensor);
					// Lets build the query to update in the device
					$url_final = $GLOBALS["dispositius"][$sendValor[0]] . "/?" . $sensor . "=" . $valor;
					//Initializing curl (like a web client without all user things)
					$curl = curl_init();
					// Reset, to not have strange errors
					curl_reset($curl);
					// Set the url (<ip_device>?<sensor>=<value>)
					curl_setopt($curl, CURLOPT_URL, $url_final);
					// Set timeout for curl process
                                        curl_setopt($curl, CURLOPT_TIMEOUT, 2);
					// Set timeout in case it doesn't connect
                                        curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 2);
					// Run curl, RUN!
					$data = curl_exec($curl);
					// In case it didn't arrived
					if ($data === FALSE) 
					{
						// Echo the error, to see what happened
						echo "Curl failed: " . curl_error($curl) . "\n";
						// Correct the sender, because he have 1, but didn't arrived!
						$correct = "{\"" . $sensor . "\":" . $GLOBALS["values"][$sensor] . "}";
						foreach ($this->clients as $client) 
						{
							if ($conn == $client) 
							{
								$client->send($correct);
							}
						}
					}
					// In case it arrived perfectly
					else
					{
						// Update the new value to the array
						$GLOBALS["values"][$sensor] = $valor;
						// Send the new value to everyone, including Christ.
						$send = "{\"" . $sensor . "\":" . $valor . "}";
						foreach ($this->clients as $client) 
						{
							//doesn't matter send to sender, but it looks cool :)
							if ($conn !== $client) 
							{
								$client->send($send);
							}
						}
					}
					// Lets close the connection.
					curl_close($curl);
				}
			}
			// If it is from the cron job (refresh.js)
			elseif(isset($array["refresh"]))
			{
				// For each device I have in the array
				foreach($GLOBALS["dispositius"] as $dispositiu => $ip){
					// Start a curl!
					$curl = curl_init();
					// Reset Reset Reset
					curl_reset($curl);
					// Gimme ip, gimme ip!!!
					// /json is configured in device
					$url_final = $ip . "/json";
					// Set url
					curl_setopt($curl, CURLOPT_URL, $url_final);
					// Set timeout for curl process
                                        curl_setopt($curl, CURLOPT_TIMEOUT, 2);
					// Set timeout for trying connect the url
                                        curl_setopt($curl, CURLOPT_CONNECTTIMEOUT, 2);
					// RUN FOREST RUN!!
					$data = curl_exec($curl);
					// In case it doesn't run fast enough
					if ($data === FALSE) 
					{
						// Echo ip unreachable and error.
						echo "Could not get ::$ip:: Curl failed: " . curl_error($curl) . "\n";
					}
					// If it could run from bully
					else
					{
						// Lets process incoming data
						$json = json_decode($data,true);
						// For each sensor, update it!
						foreach($json as $sensor => $valor){
							// I added a variable "machine_id" to external access.
							if($sensor !== "machine_id"){
								$GLOBALS["dispositius"][$sensor] = $valor;
							}
						}
						// Why not echo a good value updated ;P
						echo "Updated $sensor\n";
					}
				}
				// Send new values to all!
				$send = json_encode($GLOBALS["values"]);
				foreach ($this->clients as $client) 
				{
						$client->send($send);
				}
			}
			// In case it's from an Arduino (from updater.php -> updater.js)
			else{
				// They are "fiable" data, so lets add it!
				foreach($array as $sensor => $valor){
					// Remove the distintive variable ~~
					if($sensor !== "incoming"){
						$GLOBALS["values"][$sensor] = $valor;
					}
				}
				// After adding, send to all clients!
				$send = json_encode($GLOBALS["values"]);
				foreach ($this->clients as $client) {
					if ($conn !== $client) {
						$client->send($send);
					}
				}
			}
		}
	}
	// In case the connection closes.
	public function onClose(ConnectionInterface $conn) {
		// Remove it from the VIP list :V
		$this->clients->detach($conn);
		// Echo this guy has disconnected
		echo "Connection {$conn->resourceId} has disconnected\n";
	}
	// In case of error, we're really bad
	public function onError(ConnectionInterface $conn, \Exception $e) {
		// Echo the error (uncommon to see!)
		echo "An error has occurred: {$e->getMessage()}\n";
		// Close the connection with the guy with errors
		$conn->close();
	}
}

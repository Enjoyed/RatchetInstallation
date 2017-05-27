<?php
namespace WebSocketGerard;
use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;

$GLOBALS["values"] = array(
"d1_temperatura" => 20, "d1_led1" => 0, "d1_led2" => 0, "d1_led3" => 0, "d1_led4" => 0, "d1_led5" => 0, "d1_led6" => 0,
"d2_temperatura" => 20, "d2_led1" => 0, "d2_led2" => 0, "d2_led3" => 0, "d2_led4" => 0, "d2_led5" => 0, "d2_led6" => 0,
"d3_temperatura" => 20, "d3_led1" => 0, "d3_led2" => 0, "d3_led3" => 0, "d3_led4" => 0, "d3_led5" => 0, "d3_led6" => 0,
"d4_temperatura" => 20, "d4_led1" => 0, "d4_led2" => 0, "d4_led3" => 0, "d4_led4" => 0, "d4_led5" => 0, "d4_led6" => 0,
"d5_temperatura" => 20, "d5_led1" => 0, "d5_led2" => 0, "d5_led3" => 0, "d5_led4" => 0, "d5_led5" => 0, "d5_led6" => 0,
"d6_temperatura" => 20, "d6_led1" => 0, "d6_led2" => 0, "d6_led3" => 0, "d6_led4" => 0, "d6_led5" => 0, "d6_led6" => 0
);

$GLOBALS["dispositius"] = array(
"d1" => "10.19.250.50",
"d2" => "10.19.250.20",
"d3" => "10.19.250.30",
"d4" => "10.19.250.40",
"d5" => "10.19.250.10"
);

function isJson($string) {
	json_decode($string);
	return (json_last_error() == JSON_ERROR_NONE);
}

class Chat implements MessageComponentInterface {
	protected $clients;

	public function __construct() {
		$this->clients = new \SplObjectStorage;
	}

	public function onOpen(ConnectionInterface $conn) {
		$this->clients->attach($conn);
		$send = json_encode($GLOBALS["values"]);
		foreach ($this->clients as $client) {
			if ($conn == $client) {
				$client->send($send);
			}
		}
		echo "New connection! ({$conn->resourceId})\n";
	}
	public function onMessage(ConnectionInterface $conn, $msg) {
		$numRecv = count($this->clients) - 1;
		if(isJson($msg)) 
		{
			echo sprintf("Updating values to %d client%s" . "\n"
			,$numRecv, $numRecv == 1 ? "" : "s");
			$array = json_decode($msg);
			if(!isset($array["incoming"]))
			{
				foreach($array as $sensor => $valor) {
					$GLOBALS["values"][$sensor] = $valor;
					$sendValor = explode("_",$sensor);
					$url_final = $GLOBALS["dispositius"][$sendValor[0]] . "/?" . $sensor . "=" . $valor;
					$curl = curl_init();
					curl_reset($curl);
					curl_setopt($curl, CURLOPT_URL, $url_final);
					$data = curl_exec($curl);
					if ($data === FALSE) 
					{
						echo "Curl failed: " . curl_error($curl);
					}
					curl_close($curl);
				}
				$send = json_encode($GLOBALS["values"]);
				foreach ($this->clients as $client) 
				{
					if ($conn !== $client) 
					{
						$client->send($send);
					}
				}
			}
			else{
				foreach($array as $sensor => $valor){
					if($sensor !== "incoming"){
						$GLOBALS["values"][$sensor] = $valor;
					}
				}
				$send = json_encode($GLOBALS["values"]);
				foreach ($this->clients as $client) {
					if ($conn !== $client) {
						$client->send($send);
					}
				}
			}
		}
	}
	public function onClose(ConnectionInterface $conn) {
		$this->clients->detach($conn);
		echo "Connection {$conn->resourceId} has disconnected\n";
	}

	public function onError(ConnectionInterface $conn, \Exception $e) {
		echo "An error has occurred: {$e->getMessage()}\n";
		$conn->close();
	}
}

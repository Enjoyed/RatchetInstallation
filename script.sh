#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
        printf "CHECKS... OK";
else
        echo "Need internet access to run this scrint" 1>&2
        exit 1
fi

function _spinner() {
# FUNCIO CREADA PER TASOS LATSAS
# GITHUB: github.com/tlatsas/bash-spinner
    local on_success="DONE"
    local on_fail="FAIL"
    local white="\e[1;37m"
    local green="\e[1;32m"
    local red="\e[1;31m"
    local nc="\e[0m"
    case $1 in
        start)
            let column=$(tput cols)-${#2}-8
            echo -ne ${2}
            printf "%${column}s"
            i=1
            sp='\|/-'
            delay=${SPINNER_DELAY:-0.15}
            while :
            do
                printf "\b${sp:i++%${#sp}:1}"
                sleep $delay
            done
            ;;
        stop)
            if [[ -z ${3} ]]; then
                echo "spinner is not running.."
                exit 1
            fi
            kill $3 &>> /var/log/gerardscript.log 2>&1
            echo -en "\b["
            if [[ $2 -eq 0 ]]; then
                echo -en "${green}${on_success}${nc}"
            else
                echo -en "${red}${on_fail}${nc}"
            fi
            echo -e "]"
            ;;
        *)
            echo "invalid argument, try {start/stop}"
            exit 1
            ;;
    esac
}
function start_spinner {
    _spinner "start" "${1}" &
    _sp_pid=$!
    disown
}

function stop_spinner {
    _spinner "stop" $1 $_sp_pid
    unset _sp_pid
}

touch /var/log/gerardscript.log
echo "Initializing Gerard Script (domotica project) by Gerard Fleque"
echo "Log -> /var/log/gerardscript.log"

sleep 1

start_spinner "Updating your system..."
echo "Executant apt-get update..." >> /var/log/gerardscript.log
apt-get update &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner "Installing apache2..."
echo "Executant apt-get install apache2..." >> /var/log/gerardscript.log
apt-get install -y apache2 apache2-utils &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner "Installing PHP..."
echo "Executant apt-get install php..." >> /var/log/gerardscript.log
apt-get install -y php5 php5-json php5-dev unzip php5-curl &>> /var/log/gerardscript.log
stop_spinner $?
printf "\n"
start_spinner "Creating folders..."
echo "Creating folders..." >> /var/log/gerardscript.log
if [ ! -d "/odt/ratchet" ]; then
mkdir -p /odt/ratchet
fi
cd /odt/ratchet
if [ ! -d "/odt/ratchet/src/websocketgerard" ]; then
mkdir -p /odt/ratchet/src/websocketgerard 
fi
if [ ! -d "/odt/ratchet/bin" ]; then
mkdir /odt/ratchet/bin
fi
if [ ! -d "/var/www/html/assets/css" ]; then
mkdir -p /var/www/html/assets/css
fi
if [ ! -d "/var/www/html/assets/js" ]; then
mkdir /var/www/html/assets/js
fi
if [ ! -d "/var/www/html/assets/fonts" ]; then
mkdir /var/www/html/assets/fonts
fi
stop_spinner $?

printf "\n"
start_spinner "Downloading composer..."
cd /odt/ratchet
echo "Downloading composer..." >> /var/log/gerardscript.log
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Verifying download...'
echo "Verifying download..." >> /var/log/gerardscript.log
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Running composer installer...'
echo "Running composer installer..." >> /var/log/gerardscript.log
php composer-setup.php &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Removing composer installer...'
echo "Removing composer installer..." >> /var/log/gerardscript.log
php -r "unlink('composer-setup.php');" &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Installing Ratchet...'
echo "Installing Ratchet..." >> /var/log/gerardscript.log
php composer.phar require cboden/ratchet &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Creating namespace websocketgerard...'
echo "Creating namespace websocketgerard..." >> /var/log/gerardscript.log
printf '<?php\nnamespace WebSocketGerard;\nuse Ratchet\MessageComponentInterface;\nuse Ratchet\ConnectionInterface;\n\n$GLOBALS["values"] = array(\n	"d1_temperatura" => 20, "d1_led1" => 0, "d1_led2" => 0, "d1_led3" => 0, "d1_led4" => 0, "d1_led5" => 0, "d1_led6" => 0,\n	"d2_temperatura" => 20, "d2_led1" => 0, "d2_led2" => 0, "d2_led3" => 0, "d2_led4" => 0, "d2_led5" => 0, "d2_led6" => 0,\n	"d3_temperatura" => 20, "d3_led1" => 0, "d3_led2" => 0, "d3_led3" => 0, "d3_led4" => 0, "d3_led5" => 0, "d3_led6" => 0,\n	"d4_temperatura" => 20, "d4_led1" => 0, "d4_led2" => 0, "d4_led3" => 0, "d4_led4" => 0, "d4_led5" => 0, "d4_led6" => 0,\n	"d5_temperatura" => 20, "d5_led1" => 0, "d5_led2" => 0, "d5_led3" => 0, "d5_led4" => 0, "d5_led5" => 0, "d5_led6" => 0,\n	"d6_temperatura" => 20, "d6_led1" => 0, "d6_led2" => 0, "d6_led3" => 0, "d6_led4" => 0, "d6_led5" => 0, "d6_led6" => 0\n);\n\n$GLOBALS["dispositius"] = array(\n	"r1" => "10.19.250.50",\n	"d2" => "10.19.250.20",\n	"d3" => "10.19.250.30",\n	"d4" => "10.19.250.40",\n	"d5" => "10.19.250.10"\n	);\n\nfunction isJson($string) {\n    json_decode($string);\n    return (json_last_error() == JSON_ERROR_NONE);\n}\n\nclass Chat implements MessageComponentInterface {\n    protected $clients;\n\n    public function __construct() {\n        $this->clients = new \SplObjectStorage;\n    }\n\n    public function onOpen(ConnectionInterface $conn) {\n        // Store the new connection to send messages to later\n        $this->clients->attach($conn);\n	$send = json_encode($GLOBALS["values"]);\n        foreach ($this->clients as $client) {\n            if ($conn == $client) {\n                // The sender is not the receiver, send to each client connected\n                $client->send($send);\n            }\n        }\n        echo "New connection! ({$conn->resourceId})\n";\n    }\n    public function onMessage(ConnectionInterface $conn, $msg) {\n        $numRecv = count($this->clients) - 1;\n		if(isJson($msg)) {\n			echo sprintf("Updating values to %d client%s" . "\n"\n				,$numRecv, $numRecv == 1 ? "" : "s");\n			$array = json_decode($msg);\n			foreach($array as $sensor => $valor) {\n				$GLOBALS["values"][$sensor] = $valor;\n				$sendValor = explode("_",$sensor);\n				$url_final = $GLOBALS["dispositius"][$sendValor[0]] . "/?" . $sensor . "=" . $valor;\n				$curl = curl_init();\n				curl_reset($curl);\n				curl_setopt($curl, CURLOPT_URL, $url_final);\n				$data = curl_exec($curl);\n				if ($data === FALSE) {\n						echo "Curl failed: " . curl_error($curl);\n					}\n				curl_close($curl);\n			}\n		$send = json_encode($GLOBALS["values"]);\n			foreach ($this->clients as $client) {\n				if ($conn !== $client) {\n					// The sender is not the receiver, send to each client connected\n					$client->send($send);\n				}\n			}\n		}\n    }\n\n    public function onClose(ConnectionInterface $conn) {\n        // The connection is closed, remove it, as we can no longer send it messages\n        $this->clients->detach($conn);\n        echo "Connection {$conn->resourceId} has disconnected\n";\n    }\n\n    public function onError(ConnectionInterface $conn, Exception $e) {\n        echo "An error has occurred: {$e->getMessage()}\n";\n        $conn->close();\n    }\n}\n' > src/websocketgerard/Chat.php
stop_spinner $?

printf "\n"
start_spinner 'Creating composer.json...'
echo "Creating composer.json..." >> /var/log/gerardscript.log
cd /odt/ratchet
printf '{\n    "autoload": {\n        "psr-0": {\n            "websocketgerard": "src"\n        }\n    },\n    "require": {\n        "cboden/ratchet": "0.3.*"\n    }\n}' > /odt/ratchet/composer.json
stop_spinner $?

printf "\n"
start_spinner 'Updating composer...'
echo "Updating composer..." >> /var/log/gerardscript.log
cd /odt/ratchet
php composer.phar update &>> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Creating main server file...'
echo "Creating main server file..." >> /var/log/gerardscript.log
printf "<?php\nuse Ratchet\Server\IoServer;\nuse Ratchet\Http\HttpServer;\nuse Ratchet\WebSocket\WsServer;\nuse websocketgerard\Chat;\n    require dirname(__DIR__) . '/vendor/autoload.php';\n    \$server = IoServer::factory(\n        new HttpServer(\n            new WsServer(\n                new Chat()\n            )\n        ),\n        8080\n    );\n    \$server->run();" > /odt/ratchet/bin/server.php
stop_spinner $?

printf "\n"
start_spinner 'Downloading bootstrap...'
echo "Downloading bootstrap..." >> /var/log/gerardscript.log
cd /var/www/html/assets/css
wget https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css &>> /var/log/gerardscript.log
cd /var/www/html/assets/js
wget https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js &>> /var/log/gerardscript.log
printf 'h3 {\n	text-align:center;\n}\np {\n	margin-top:0.3vw;\n	text-align:center;\n	font-size:calc(1vw + 1vh);\n}\n.row {\n	padding: 6px;\n	border-style: solid;\n    border-color: #0000ff;\n	border-width: 0px 2px 0px 0px;\n}\nspan {\n	font-size:calc(1vw + 1vh);\n	font-weight: bold;\n}\n.biggerrow {\n	border-style:none;\n}\n.lastrow {\n	border-style: none;\n	border-width: 0px 0px 0px 0px;\n}' > /var/www/html/assets/css/custom-css.css
stop_spinner $?

printf "\n"
start_spinner 'Downloading jQuery...'
cd /var/www/html/assets/js
wget https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js &>> /var/log/gerardscript.log
echo "Downloading jQuery..." >> /var/log/gerardscript.log
stop_spinner $?

printf "\n"
start_spinner 'Downloading and installing FontAwesome...'
echo "Downloading FontAwesome..." >> /var/log/gerardscript.log
cd ~/
wget fontawesome.io/assets/font-awesome-4.7.0.zip &>> /var/log/gerardscript.log
unzip font-awesome-4.7.0.zip &>> /var/log/gerardscript.log
cd font-awesome-4.7.0
yes | cp -rf * /var/www/html/assets/
rm -rf ~/font-awesome*
stop_spinner $?
sleep 1
printf "\n"
start_spinner 'Making run on startup...'
echo "Making run on startup..." >> /var/log/gerardscript.log
echo "php /odt/ratchet/bin/server.php" >> /etc/rc.local
stop_spinner $?
sleep 1
printf "\n"
start_spinner 'Setting the default template...'
echo "Setting the default template..." >> /var/log/gerardscript.log
printf '<html>\n	<head>\n		<meta content="text/html;charset=utf-8" http-equiv="Content-Type">\n		<meta content="utf-8" http-equiv="encoding">\n	</head>\n<link rel="stylesheet" href="assets/css/bootstrap.min.css">\n<link rel="stylesheet" href="assets/css/font-awesome.min.css">\n<link rel="stylesheet" href="assets/css/custom-css.css">\n<script src="assets/js/jquery.min.js"></script>\n<script src="assets/js/bootstrap.min.js"></script>\n	<body>\n		<div class="container-fluid">\n		<!-- PRIMERA LINIA (dispositiu 1 - 6) -->\n		<!-- COMENÇAMENT DISPOSITIU 1 -->\n			<div class="row biggerrow">\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 1\n					</h3>\n					<div class="row">\n						<div class="col-md-8">\n							<p>\n								<span>Temperatura:<span>\n							</p>\n						</div>\n						<div class="col-md-4">\n							<p id="d1_temperatura" tipo="sensor">\n								0\n							</p>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED1\n							 </p>\n						</div>\n						<div class="col-md-5" align="center" align="center">\n							<a class="btn btn-danger" id="d1_led1" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7"  style="font-size: 1em">\n							 <p>\n								LED2\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d1_led2" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED3\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d1_led3" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED4\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d1_led4" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED5\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d1_led5" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED6\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d1_led6" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n				</div>\n				<!-- FI DISPOSITIU 1 -->\n				<!-- COMENÇAMENT DISPOSITIU 2 -->\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 2\n					</h3>\n					<div class="row">\n						<div class="col-md-8">\n							<p>\n								<span>Temperatura:<span>\n							</p>\n						</div>\n						<div class="col-md-4">\n							<p id="d2_temperatura" tipo="sensor">\n								0\n							</p>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED1\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d2_led1" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7"  style="font-size: 1em">\n							 <p>\n								LED2\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d2_led2" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED3\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d2_led3" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED4\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d2_led4" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED5\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d2_led5" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED6\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d2_led6" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n				</div>\n				<!-- FI DISPOSITIU 2 -->\n				<!-- COMENÇAMENT DISPOSITIU 3 -->\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 3\n					</h3>\n					<div class="row">\n						<div class="col-md-8">\n							<p>\n								<span>Temperatura:<span>\n							</p>\n						</div>\n						<div class="col-md-4">\n							<p id="d3_temperatura" tipo="sensor">\n								0\n							</p>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED1\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d3_led1" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7"  style="font-size: 1em">\n							 <p>\n								LED2\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d3_led2" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED3\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d3_led3" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED4\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d3_led4" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED5\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d3_led5" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED6\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d3_led6" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n				</div>\n				<!-- FI DISPOSITIU 3 -->\n				<!-- COMENÇAMENT DISPOSITIU 4 -->\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 4\n					</h3>\n					<div class="row">\n						<div class="col-md-8">\n							<p>\n								<span>Temperatura:<span>\n							</p>\n						</div>\n						<div class="col-md-4">\n							<p id="d4_temperatura" tipo="sensor">\n								0\n							</p>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED1\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d4_led1" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7"  style="font-size: 1em">\n							 <p>\n								LED2\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d4_led2" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED3\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d4_led3" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED4\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d4_led4" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED5\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d4_led5" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED6\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d4_led6" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n				</div>\n				<!-- FI DISPOSITIU 4 -->\n				<!-- COMENÇAMENT DISPOSITIU 5 -->\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 5\n					</h3>\n					<div class="row">\n						<div class="col-md-8">\n							<p>\n								<span>Temperatura:<span>\n							</p>\n						</div>\n						<div class="col-md-4">\n							<p id="d5_temperatura" tipo="sensor">\n								0\n							</p>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED1\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d5_led1" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7"  style="font-size: 1em">\n							 <p>\n								LED2\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d5_led2" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED3\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d5_led3" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED4\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d5_led4" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED5\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d5_led5" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row">\n						<div class="col-md-7">\n							 <p>\n								LED6\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d5_led6" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n				</div>\n				<!-- FI DISPOSITIU 5 -->\n				<!-- COMENÇAMENT DISPOSITIU 6 -->\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 6\n					</h3>\n					<div class="row lastrow">\n						<div class="col-md-8">\n							<p>\n								<span>Temperatura:<span>\n							</p>\n						</div>\n						<div class="col-md-4">\n							<p id="d6_temperatura" tipo="sensor">\n								0\n							</p>\n						</div>\n					</div>\n					<div class="row lastrow">\n						<div class="col-md-7">\n							 <p>\n								LED1\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d6_led1" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row lastrow">\n						<div class="col-md-7"  style="font-size: 1em">\n							 <p>\n								LED2\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d6_led2" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row lastrow">\n						<div class="col-md-7">\n							 <p>\n								LED3\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d6_led3" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row lastrow">\n						<div class="col-md-7">\n							 <p>\n								LED4\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d6_led4" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row lastrow">\n						<div class="col-md-7">\n							 <p>\n								LED5\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d6_led5" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n					<div class="row lastrow">\n						<div class="col-md-7">\n							 <p>\n								LED6\n							 </p>\n						</div>\n						<div class="col-md-5" align="center">\n							<a class="btn btn-danger" id="d6_led6" tipo="onoff">\n								OFF\n							</a>\n						</div>\n					</div>\n				</div>\n			</div>\n			<!-- SEGONA LINIA (dispositiu 7 - 12) -->\n			<div class="row biggerrow">\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 7\n					</h3>\n				</div>\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 8\n					</h3>\n				</div>\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 9\n					</h3>\n				</div>\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 10\n					</h3>\n				</div>\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 11\n					</h3>\n				</div>\n				<div class="col-md-2">\n					<h3>\n						Dispositiu 12\n					</h3>\n				</div>\n			</div>\n		</div>\n	<script>\n	var conn = new WebSocket("ws://10.19.250.1:8080");\n	conn.onopen = function(e) {\n		console.log("Connection established!");\n	};\n	conn.onmessage = function(e) {\n		console.log(e.data);\n		console.log("Actualitzacio");\n		Data = JSON.parse(e.data);\n		for (var prop in Data) {\n			var element = document.getElementById(prop);\n			var type = $(element).attr("tipo");\n			if(type == "onoff") {\n				switch(Data[prop]) {\n					case 0:\n						element.innerHTML = "OFF";\n						element.classList.remove("btn-success");\n						element.classList.add("btn-danger");\n						break;\n					case 1:\n						element.innerHTML = "ON";\n						element.classList.remove("btn-danger");\n						element.classList.add("btn-success");\n						break;\n				}\n			}\n			else if(type == "sensor")\n			{\n				element.innerHTML = Data[prop];\n			}\n		}\n	}\n	function changeClass()\n		{\n			var nom = $(this).attr("id");\n			if(this.innerHTML == "ON"){\n				var valor = 0;\n			}\n			else if(this.innerHTML == "OFF"){\n				var valor = 1;\n			}\n			sendMessage(nom,valor);\n			$(this).toggleClass("btn-success");\n			$(this).toggleClass("btn-danger");\n			if(this.innerHTML == "ON"){\n					this.innerHTML = "OFF";\n			}\n			else{\n					this.innerHTML = "ON";\n			}\n			color_id = $(this).attr("id").toUpperCase();\n			value_color = $(this).html();\n		}\n	window.onload = function()\n	{\n		document.getElementById("d1_led1").addEventListener( "click", changeClass);\n		document.getElementById("d1_led2").addEventListener( "click", changeClass);\n		document.getElementById("d1_led3").addEventListener( "click", changeClass);\n		document.getElementById("d1_led4").addEventListener( "click", changeClass);\n		document.getElementById("d1_led5").addEventListener( "click", changeClass);\n		document.getElementById("d1_led6").addEventListener( "click", changeClass);\n		document.getElementById("d2_led1").addEventListener( "click", changeClass);\n		document.getElementById("d2_led2").addEventListener( "click", changeClass);\n		document.getElementById("d2_led3").addEventListener( "click", changeClass);\n		document.getElementById("d2_led4").addEventListener( "click", changeClass);\n		document.getElementById("d2_led5").addEventListener( "click", changeClass);\n		document.getElementById("d2_led6").addEventListener( "click", changeClass);\n		document.getElementById("d3_led1").addEventListener( "click", changeClass);\n		document.getElementById("d3_led2").addEventListener( "click", changeClass);\n		document.getElementById("d3_led3").addEventListener( "click", changeClass);\n		document.getElementById("d3_led4").addEventListener( "click", changeClass);\n		document.getElementById("d3_led5").addEventListener( "click", changeClass);\n		document.getElementById("d3_led6").addEventListener( "click", changeClass);\n		document.getElementById("d4_led1").addEventListener( "click", changeClass);\n		document.getElementById("d4_led2").addEventListener( "click", changeClass);\n		document.getElementById("d4_led3").addEventListener( "click", changeClass);\n		document.getElementById("d4_led4").addEventListener( "click", changeClass);\n		document.getElementById("d4_led5").addEventListener( "click", changeClass);\n		document.getElementById("d4_led6").addEventListener( "click", changeClass);\n		document.getElementById("d5_led1").addEventListener( "click", changeClass);\n		document.getElementById("d5_led2").addEventListener( "click", changeClass);\n		document.getElementById("d5_led3").addEventListener( "click", changeClass);\n		document.getElementById("d5_led4").addEventListener( "click", changeClass);\n		document.getElementById("d5_led5").addEventListener( "click", changeClass);\n		document.getElementById("d5_led6").addEventListener( "click", changeClass);\n		document.getElementById("d6_led1").addEventListener( "click", changeClass);\n		document.getElementById("d6_led2").addEventListener( "click", changeClass);\n		document.getElementById("d6_led3").addEventListener( "click", changeClass);\n		document.getElementById("d6_led4").addEventListener( "click", changeClass);\n		document.getElementById("d6_led5").addEventListener( "click", changeClass);\n		document.getElementById("d6_led6").addEventListener( "click", changeClass);\n	}\n	function sendMessage(text, valor) {\n		var json = "{\\"" + text + "\\":" + valor + "}";\n		conn.send(json);\n		console.log(json);\n	}\n	</script>\n	</body>\n</html>' > /var/www/html/index.html
stop_spinner $?
sleep 1
printf "\n"
start_spinner 'Setting the web updaters...'
echo "Setting the web updaters..." >> /var/log/gerardscript.log
printf '<?php\nif(count($_GET)) {\necho "<script>";\necho "var conn = new WebSocket(\"ws://localhost:8080\");";\necho "conn.onopen = function(e) {";\necho "var vars = {};";\necho    "var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi,";\necho    "function(m,key,value) {";\necho     "vars[key] = value; });";\necho     "var send = JSON.stringify(vars);";\necho    "console.log(send);";\necho    "conn.send(send);";\necho    "conn.close;";\necho "};";\necho "</script>";\n}\n?>' > /var/www/html/update.php
printf '<?php\n$connecting_as = $_SERVER["REMOTE-ADDR"];\n$accepted = array(\n	"10.19.250.10",\n	"10.19.250.20",\n	"10.19.250.30",\n	"10.19.250.40",\n	"10.19.250.50"\n)\nif(in_array($connecting_as, $accepted))\n{\n	if(count($_GET))\n	{\n		$query = $_SERVER[QUERY_STRING];\n		$curl = curl_init();\n		$url_final = "http://localhost/private.php?" . $query;\n		curl_setopt($curl, CURLOPT_URL, $url_final);\n		$output = curl_exec($curl);\n		curl_close($curl);\n	}\n}\n?>\n\n' > /var/www/html/private.php
stop_spinner $?
sleep 1
printf "\n"
start_spinner 'Modifying permissions...'
echo "Modifying permissions..." >> /var/log/gerardscript.log
chmod 755 -R /odt/ratchet
stop_spinner $?

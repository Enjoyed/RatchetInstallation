#!/bin/bash
if [ -f "/etc/init.d/functions.sh" ]; then
. /etc/init.d/functions.sh
else
ScriptLoc=$(readlink -f "$0")
chmod ugo+x "$ScriptLoc"
fi

touch /var/log/gerardscript.log


printf 'CHECKS... '
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
wget -q --tries=10 --timeout=20 --spider http://google.com
if [[ $? -eq 0 ]]; then
        true
else
        echo "Need internet access to run this scrint" 1>&2
        exit 1
fi
printf '[\e[1;32mDONE\e[0m]\n'


if [ ! -f "/etc/init.d/functions.sh" ]; then
	git clone https://github.com/marcusatbang/efunctions.git /opt/efunctions &>> /var/log/gerardscript.log
	cd /opt/efunctions
	./install.sh &>> /var/log/gerardscript.log
	exec "$ScriptLoc"
fi
clear
printf "Initializing Gerard Script (domotica project) by Gerard Fleque"
printf "\nLog -> /var/log/gerardscript.log\n\n"

sleep 3

echo "Executant apt-get update..." >> /var/log/gerardscript.log
ebegin "Updating your system..."
apt-get update &>> /var/log/gerardscript.log
eend $?

echo "Installing apache2..." >> /var/log/gerardscript.log
ebegin "Installing apache2..."
apt-get -qq install -y apache2 apache2-utils &>> /var/log/gerardscript.log
eend $?

echo "Installing PHP..." >> /var/log/gerardscript.log
ebegin "Installing PHP..."
apt-get -qq install -y php5 php5-json php5-dev php5-curl &>> /var/log/gerardscript.log
eend $?

echo "Installing other necessary packets..." >> /var/log/gerardscript.log
ebegin "Installing other necessary packets..."
apt-get -qq install -y nodejs npm &>> /var/log/gerardscript.log
eend $?

echo "Creating folders..." >> /var/log/gerardscript.log
ebegin "Creating needed structure..."
if [ ! -d "/opt/websocket" ]; then
mkdir -p /opt/websocket
fi
if [ ! -d "/opt/websocket/src/websocketgerard" ]; then
mkdir -p /opt/websocket/src/websocketgerard 
fi
if [ ! -d "/opt/websocket/bin" ]; then
mkdir /opt/websocket/bin
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
if [ ! -d "/tmp/RatchetInstallation" ]; then
mkdir /tmp/RatchetInstallation
fi
eend $?

ebegin "Downloading ProjectCode (source files)..."
cd /opt/websocket
echo "Downloading ProjectCode (source files)..." >> /var/log/gerardscript.log
git clone https://github.com/Enjoyed/RatchetInstallation /tmp/RatchetInstallation &>> /var/log/gerardscript.log
eend $?

einfo "Installing composer..."
eindent

ebegin "Downloading Composer..."
cd /opt/websocket
echo "Downloading composer..." >> /var/log/gerardscript.log
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &>> /var/log/gerardscript.log
eend $?

ebegin "Verifying download..."
cd /opt/websocket
echo "Verifying download..." >> /var/log/gerardscript.log
php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &>> /var/log/gerardscript.log
eend $?

ebegin "Running composer installer..."
cd /opt/websocket
echo "Running composer installer..." >> /var/log/gerardscript.log
php composer-setup.php &>> /var/log/gerardscript.log
eend $?

ebegin "Removing composer installer..."
cd /opt/websocket
echo "Removing composer installer..." >> /var/log/gerardscript.log
php -r "unlink('composer-setup.php');" &>> /var/log/gerardscript.log
eend $?
eoutdent

ebegin "Installing Ratchet..."
cd /opt/websocket
echo "Installing Ratchet..." >> /var/log/gerardscript.log
php composer.phar require cboden/ratchet &>> /var/log/gerardscript.log
eend $?

ebegin "Setting server environment..."
echo "Setting server environment..." >> /var/log/gerardscript.log
cd /opt/websocket
yes | cp -rf /tmp/RatchetInstallation/Chat.php /opt/websocket/src/websocketgerard/Chat.php
yes | cp -rf /tmp/RatchetInstallation/composer.json /opt/websocket/composer.json
yes | cp -rf /tmp/RatchetInstallation/server.php /opt/websocket/bin/server.php
yes | cp -rf /tmp/RatchetInstallation/updater.js /opt/websocket/updater.js
yes | cp -rf /tmp/RatchetInstallation/refresh.js /opt/websocket/refresh.js
yes | cp -rf /tmp/RatchetInstallation/check.sh /opt/websocket/check.sh
eend $?

ebegin "Setting web environment..."
echo "Setting web environment..." >> /var/log/gerardscript.log
NEWIP=$(ip route get 1 | awk '{print $NF;exit}')
yes | cp -rf /tmp/RatchetInstallation/index.html /var/www/html/index.html
yes | cp -rf /tmp/RatchetInstallation/custom.css /var/www/html/assets/css/custom.css
yes | cp -rf /tmp/RatchetInstallation/updater.php /var/www/html/updater.php
yes | cp -rf /tmp/RatchetInstallation/index.html /var/www/html/index.html
sed -i.bak "s/10.19.250.1/$NEWIP/g" /var/www/html/index.html
eend $?

echo "Updating composer..." >> /var/log/gerardscript.log
ebegin "Updating composer..."
cd /opt/websocket
php composer.phar update &>> /var/log/gerardscript.log
eend $?

echo "Installing websocket client..." >> /var/log/gerardscript.log
ebegin "Installing websocket client..."
cd /opt/websocket
npm install --silent -g node-gyp &>> /var/log/gerardscript.log
npm install --silent websocket &>> /var/log/gerardscript.log
eend $?

echo "Downloading bootstrap..." >> /var/log/gerardscript.log
ebegin "Downloading bootstrap..."
cd /var/www/html/assets/css
wget https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css &>> /var/log/gerardscript.log
cd /var/www/html/assets/js
wget https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js &>> /var/log/gerardscript.log
eend $?

echo "Downloading jQuery..." >> /var/log/gerardscript.log
ebegin "Downloading jQuery..."
cd /var/www/html/assets/js
wget https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js &>> /var/log/gerardscript.log
eend $?

echo "Making run on apache run..." >> /var/log/gerardscript.log
ebegin "Making run on apache run..."
sed -i.bak "/  start)/!{p;d;};n;n;a php -q /opt/websocket/bin/server.php &" /etc/init.d/apache2
eend $?

echo "Creating refresh task..." >> /var/log/gerardscript.log
ebegin "Creating refresh task..."
crontab -l > mycron
echo "* * * * * bash /opt/websocket/check.sh" >> mycron
echo "* * * * * (sleep 30; bash /opt/websocket/check.sh)" >> mycron
crontab mycron
rm mycron
eend $?

echo "Modifying permissions..." >> /var/log/gerardscript.log
ebegin "Modifying permissions..."
chmod 775 -R /opt/websocket
chmod 775 -R /var/www/html/
eend $?

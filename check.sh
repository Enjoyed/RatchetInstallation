#!/bin/sh
SERVICE='php -q /opt/websocket/bin/server.php &'
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    nodejs /opt/websocket/refresh.js
fi

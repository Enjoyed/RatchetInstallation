#!/bin/sh
# Set the command we want to check
SERVICE='php -q /opt/websocket/bin/server.php &'
# Si existeix, executa
if ps ax | grep -v grep | grep $SERVICE > /dev/null
then
    # Per actualitzar les dades comprobant els arduinos.
    nodejs /opt/websocket/refresh.js
fi

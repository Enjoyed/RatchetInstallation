#!/usr/bin/nodejs
var W3CWebSocket = require('websocket').w3cwebsocket;

if (process.argv.length <= 2) {
    console.log("Usage: " + __filename + " new values");
    process.exit(-1);
}

var values = {};
values["refresh"] = true;
var send = JSON.stringify(values);
var client = new W3CWebSocket('ws://localhost:8080/');

client.onerror = function(e) {
    console.log('Connection Error');
};

client.onopen = function() {
    console.log('WebSocket Client Connected');
    if (client.readyState === client.OPEN) {
        client.send(send.toString());
        client.close();
    }
};

client.onclose = function() {
    console.log('Client Closed');
};

#!/usr/bin/nodejs
var W3CWebSocket = require('websocket').w3cwebsocket;

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

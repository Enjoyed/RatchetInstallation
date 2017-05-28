#!/usr/bin/nodejs
var W3CWebSocket = require('websocket').w3cwebsocket;
// Initialize the array values
var values = {};
// Set our identificative variable
values["refresh"] = true;
// Lets JSONize it!
var send = JSON.stringify(values);
// Connect to the websocket
var client = new W3CWebSocket('ws://localhost:8080/');

// In case of Error
client.onerror = function(e) {
    // Echo that something went wrong
    console.log('Connection Error');
};

// When we start a connection;
client.onopen = function() {
    // Echo that we connected right
    console.log('WebSocket Client Connected');
    // Quan estigui disponible
    if (client.readyState === client.OPEN) {
        // Send our array (only has {"refresh":true}) but enough to distinct.
        client.send(send.toString());
        // Close connection, the job was done.
        client.close();
    }
};
// In case the client/server Close the connection
client.onclose = function() {
    // Echo that it was closed.
    console.log('Client Closed');
};

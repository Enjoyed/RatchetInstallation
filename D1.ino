#include <Arduino.h>
#include <ESP8266WiFi.h>  //https://github.com/esp8266/Arduino
#include <DNSServer.h>
#include <Adafruit_Sensor.h>  //https://github.com/adafruit/Adafruit_Sensor
#include <ESP8266WebServer.h>
#include <WiFiManager.h>    //https://github.com/tzapu/WiFiManager
#include <ESP8266HTTPClient.h>

ESP8266WebServer webserver(80);
WiFiClient client;
const int oneWirePin = 2;
const int pResistor = A0; 
int timer = 0;
int llum = 0;
String last_value = "";
String new_value = "";
String _id = "d1";
String string = "";
String nom = "";
String valor = "";

void setup() {
    pinMode(pResistor, INPUT);
    Serial.begin(115200);
    WiFiManager wifiManager;
    //wifiManager.resetSettings();
    wifiManager.setAPStaticIPConfig(IPAddress(10,19,250,110), IPAddress(10,19,0,1), IPAddress(255,255,0,0));
    wifiManager.setSTAStaticIPConfig(IPAddress(10,19,250,110),IPAddress(10,19,0,1),IPAddress(255,255,0,0));
    wifiManager.autoConnect("Access D1");
    Serial.println("connected... :)");
    webserver.on("/", [](){
      webserver.send(200, "text/html", "");
    });
    webserver.on("/json", [](){
      webserver.send(200, "text/html", Buildjson());
    });
    webserver.begin();
    Serial.println("EVERYTHING DONE! Working...");
}
 
void loop() {
    webserver.handleClient();
    if(webserver.args() != 0)
    {
      for (int i = 0; i < webserver.args(); i++) {
        nom = webserver.argName(i);
        valor = webserver.arg(i);
        new_value = nom + ":" + valor;
        if(last_value != new_value){    
          last_value = new_value;
        }
      }
    }
    if(timer > 50)
    {
      Serial.println("Starting send update");
      HTTPClient http;
      llum = analogRead(pResistor);
      string = "http://10.19.250.1/updater.php?d1_luminositat=" + String(llum) + "";
      Serial.println(string);
      http.begin(string);
      int httpCode = http.GET();
      if(httpCode > 0) {
        if(httpCode == HTTP_CODE_OK) {
          Serial.println("OK");
        }
      }
      else
      {
        Serial.println("Could not connect to the updater");
      }
      http.end();
      timer = 0;
    }

    timer++;
    delay(10);
}

String Buildjson()
   {
      Serial.println("Peticio JSON");
      String json = "{\"d1_luminositat\":\"" + String(llum) + "\"}";
      return json;
      delay(1);
   }

#include <Arduino.h>
#include <ESP8266WiFi.h>  //https://github.com/esp8266/Arduino
#include <DNSServer.h>
#include <Adafruit_Sensor.h>  //https://github.com/adafruit/Adafruit_Sensor
#include <ESP8266WebServer.h>
#include <WiFiManager.h>    //https://github.com/tzapu/WiFiManager
#include <ESP8266HTTPClient.h>

ESP8266WebServer webserver(80);
WiFiClient client;
int timer = 0;
String last_value = "";
String new_value = "";
String _id = "RELE1";
int r1 = 1;
int r2 = 1;
int r3 = 1;
int r4 = 1;
int r5 = 1;
int r6 = 1;
int r7 = 1;
int r8 = 1;
String ip = "";
String string = "";

int pr1 = D0;
int pr2 = D1;
int pr3 = D2;
int pr4 = D3;
int pr5 = D4;
int pr6 = D5;
int pr7 = D6;
int pr8 = D7;

String nom = "";
String valor = "";

void setup() {
      pinMode(pr1, OUTPUT);
      pinMode(pr2, OUTPUT);
      pinMode(pr3, OUTPUT);
      pinMode(pr4, OUTPUT);
      pinMode(pr5, OUTPUT);
      pinMode(pr6, OUTPUT);
      pinMode(pr7, OUTPUT);
      pinMode(pr8, OUTPUT);
    Serial.begin(115200);
    WiFiManager wifiManager;
    //wifiManager.resetSettings();
    wifiManager.setAPStaticIPConfig(IPAddress(10,19,250,100), IPAddress(10,19,0,1), IPAddress(255,255,0,0));
    wifiManager.setSTAStaticIPConfig(IPAddress(10,19,250,100),IPAddress(10,19,0,1),IPAddress(255,255,0,0));
    wifiManager.autoConnect("Access RELE1");
    Serial.println("connected... :)");
    Serial.print("Setting all pins to LOW... ");
      digitalWrite(pr1, HIGH);
      digitalWrite(pr2, HIGH);
      digitalWrite(pr3, HIGH);
      digitalWrite(pr4, HIGH);
      digitalWrite(pr5, HIGH);
      digitalWrite(pr6, HIGH);
      digitalWrite(pr7, HIGH);
      digitalWrite(pr8, HIGH);
    
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
          if(nom == "r1_r1"){
            r1 = valor.toInt();
            if(r1){
              digitalWrite(pr1,HIGH);
            }
            else{
              digitalWrite(pr1,LOW);
            }
            Serial.println("Modificat r1:" + valor);
          }
          if(nom == "r1_r2"){
            r2 = valor.toInt();
            if(r2){
              digitalWrite(pr2,HIGH);
            }
            else{
              digitalWrite(pr2,LOW);
            }
            Serial.println("Modificat r2:" + valor);
          }
          if(nom == "r1_r3"){
            r3 = valor.toInt();
            if(r3){
              digitalWrite(pr3,HIGH);
            }
            else{
              digitalWrite(pr3,LOW);
            }
            Serial.println("Modificat r3:" + valor);
          }
          if(nom == "r1_r4"){
            r4 = valor.toInt();
            if(r4){
              digitalWrite(pr4,HIGH);
            }
            else{
              digitalWrite(pr4,LOW);
            }
            Serial.println("Modificat r4:" + valor);
          }
          if(nom == "r1_r5"){
            r5 = valor.toInt();
            if(r5){
              digitalWrite(pr5,HIGH);
            }
            else{
              digitalWrite(pr5,LOW);
            }
            Serial.println("Modificat r5:" + valor);
          }
          if(nom == "r1_r6"){
            r6 = valor.toInt();
            if(r6){
              digitalWrite(pr6,HIGH);
            }
            else{
              digitalWrite(pr6,LOW);
            }
            Serial.println("Modificat r6:" + valor);;
          }
          if(nom == "r1_r7"){
            r7 = valor.toInt();
            if(r7){
              digitalWrite(pr7,HIGH);
            }
            else{
              digitalWrite(pr7,LOW);
            }
            Serial.println("Modificat r7:" + valor);
          }
          if(nom == "r1_r8"){
            r8 = valor.toInt();
            if(r8){
              digitalWrite(pr8,HIGH);
            }
            else{
              digitalWrite(pr8,LOW);
            }
            Serial.println("Modificat r8:" + valor);
          }    
          last_value = new_value;
        }
      }
    }
    delay(10);
}

String Buildjson()
   {
      Serial.println("Peticio JSON");
      String json = "{\"_id\":\"" + _id + "\",\"r1\":\"" + String(r1) + "\",\"r2\":\"" + String(r2) + "\",\"r3\":\"" + String(r3) + "\",\"r4\":\"" + String(r4) + "\",\"r5\":\"" + String(r5) + "\",\"r6\":\"" + String(r6) + "\",\"r7\":\"" + String(r7) + "\",\"r8\":\"" + String(r8) + "\"}";
      return json;
      delay(1);
   }

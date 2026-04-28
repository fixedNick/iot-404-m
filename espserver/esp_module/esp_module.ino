#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <SoftwareSerial.h>
#include <ArduinoJson.h>
#include <PubSubClient.h>

// Укажите данные вашей сети
const char* ssid = "Keenetic-8324";
const char* password = "77bis20-227-ogj";
const char* mqtt_server = "176.109.106.237";

#define ESP_RX 4 // 4 // GPIO4
#define ESP_TX 5 // 3 // GPIO5

// 
SoftwareSerial arduinoSerial(ESP_RX, ESP_TX);

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
  arduinoSerial.begin(9600);
  arduinoSerial.listen();
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }

  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);
}

// Прием команд из облака (Go -> MQTT -> ESP)
void callback(char* topic, byte* payload, unsigned int length) {
  char topCopy[64]; // Запас под длину топика
  strncpy(topCopy, topic, sizeof(topCopy) - 1);
  topCopy[sizeof(topCopy) - 1] = '\0';

  char message[length + 1];
  memcpy(message, payload, length);
  message[length] = '\0'; 

  byte buffalo[length + 1];
  memcpy(buffalo, payload, length);
  buffalo[length] = '\0'; 

  if (strcmp(topCopy, "sensors/control") == 0) {
    StaticJsonDocument<200> doc;
    deserializeJson(doc, buffalo, length);

    if (doc["cmd"] == "GET") {
      if (doc["sensor"] == "wind" || doc["sensor"] == "temperature" || doc["sensor"] == "humidity") {
        serializeJson(doc, arduinoSerial);
        arduinoSerial.print('\n');
        delay(10);
      }
    }
  }
}


void reconnect() {
  while (!client.connected()) {
    if (client.connect("ESP8266_Client")) {
      client.subscribe("sensors/control");
    } else {
      delay(5000);
    }
  }
}

unsigned long lastMsg = 0;
bool heartBeat = false;
void loop() {
  if (!client.connected()) reconnect();
  client.loop();

 if (arduinoSerial.available()) {
  String input = arduinoSerial.readStringUntil('\n');
  input.trim();

  if (input.length() > 0) {
    // client.publish("test/t", input.c_str());
    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, input);

    if (!error) {
      // client.publish("test/t", "JSON OK");
      
      StaticJsonDocument<256> rdoc;
      const char* sPath = "sensors/data/unknown";
      bool knownSensor = false;

      if (doc["sensor"] == "wind") {
        sPath = "sensors/data/wind";
        rdoc["voltage"] = doc["voltage"];
        rdoc["speed"] = doc["speed"];
        knownSensor = true;
      } else if (doc["sensor"] == "temperature") {
        sPath = "sensors/data/temperature";
        rdoc["temperature"] = doc["temperature"];
        knownSensor = true;
      } else if (doc["sensor"] == "humidity") {
        sPath = "sensors/data/humidity";
        rdoc["humidity"] = doc["humidity"];
        knownSensor = true;
      }

      if (knownSensor) {
        char buffer[256];
        serializeJson(rdoc, buffer);
        client.publish(sPath, buffer);
      }
    } else {
      // todo: sensors/errors
      // Если ошибка парсинга, пишем в отладку саму строку
      // String errMsg = "JSON Err: " + input;
      // client.publish("test/t", errMsg.c_str());
    }
  }
 }
}
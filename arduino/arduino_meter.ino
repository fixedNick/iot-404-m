#include <Wire.h> 
#include <LiquidCrystal_I2C.h>
#include <SoftwareSerial.h>
#include <ArduinoJson.h>
#include "DHT.h"

DHT dht(DHTPIN, DHT11);

#define INPUT_VOLTAGE_PIN A0
#define INPUT_TEMP_PIN A1
#define INPUT_HUMIDITY_PIN 2

#define SPEED_MLT 21.375

#define ARDUINO_GSM_RX_PIN 3
#define ARDUINO_GSM_TX_PIN 4

#define ARDUINO_ESP_RX_PIN 6
#define ARDUINO_ESP_TX_PIN 5

//SoftwareSerial gsmSerial(ARDUINO_GSM_RX_PIN, ARDUINO_GSM_TX_PIN);
SoftwareSerial espSerial(ARDUINO_ESP_RX_PIN, ARDUINO_ESP_TX_PIN);

//LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {
	// lcd.begin();
  espSerial.begin(9600);
  // espSerial.listen();
  // gsmSerial.begin(9600);
  dht.begin();
  pinMode(INPUT_VOLTAGE_PIN, INPUT);
  //setupDisplay();
}
char voltBuffer[10];
char speedbuffer[10];

void loop() {
  // float voltage = getVoltageAvg();
  // printOnDisplay(voltage);
  if (espSerial.available() > 0) {

    String input = espSerial.readStringUntil('\n');
    input.trim();
    if (input.length() > 0) {

      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, input);

      if (!error) {
       
        const char* cmd = doc["cmd"];
        const char* sensor = doc["sensor"];

        if (doc["cmd"] == "GET") {
            if (doc["sensor"] == "wind") {
              float voltage = getVoltageAvg();
              doc["voltage"] = voltage;
              doc["speed"] = voltage * SPEED_MLT;
              sendResponse(espSerial, doc);
            }
            else if (strcmp(sensor, "temperature") == 0) {
              doc["temperature"] = getTemperature();
              sendResponse(espSerial, doc);
            } 
            else if (strcmp(sensor, "humidity") == 0) {
                doc["humidity"] = getHumidity();
                sendResponse(espSerial, doc);
            }
        }
      }
    }
  }
}

float getHumidity() {
  float h = dht.readHumidity();
  if (isnan(h)) {
    return 0.0;
  }
  return h;
}

void sendResponse(SoftwareSerial to, StaticJsonDocument<200> resp) {
  serializeJson(resp, to);
  to.println(); // Конец пакета
}

// void setupDisplay() {
//   lcd.backlight();
//   lcd.noBlink();
//   lcd.noCursor();
// 	lcd.print("Hello, Eduard!");
//   lcd.setCursor(0,1);
//   lcd.print("Preparing...");
//   delay(500);
  
//   lcd.clear();
//   lcd.setCursor(3,0);
//   lcd.print("v: ");
//   lcd.setCursor(3,1);
//   lcd.print("s: ");
// }
// void printOnDisplay(float voltage) {
//   lcd.setCursor(6,0);
//   lcd.print("         ");
//   lcd.setCursor(6, 0);
//   dtostrf(voltage, 6, 3, voltBuffer);
//   lcd.print(voltBuffer);

//   lcd.setCursor(6,1);
//   lcd.print("         ");
//   lcd.setCursor(6, 1);
//   dtostrf(voltage * SPEED_MLT, 6, 3, speedbuffer);
//   float f = voltage;
//   lcd.print(speedbuffer);
// }

float getVoltageAvg() {
  long sum = 0;
  for(int i = 0; i < 10; i++) {
    sum += analogRead(INPUT_VOLTAGE_PIN);
    delay(2);
  }
  float rawInput = sum / 10.0;
  if (rawInput < 2.0) return 0; 
  
  float temp = (rawInput * 5.0) / 1023.0;
  float voltage = temp;
  return (voltage < 0) ? 0 : voltage;
}

float getTemperature() {
  float raw = analogRead(INPUT_TEMP_PIN);
  float temp = raw/1023.0*500.0;
  return temp;
}
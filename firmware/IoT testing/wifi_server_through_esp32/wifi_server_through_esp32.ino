#include <WiFi.h>
#include <WebServer.h>

const char* ssid = "ESP32_Audio";
const char* password = "12345678";  // Must be at least 8 chars

WebServer server(80);

const int micPin = 32;

void handleData() {
  int soundVal = analogRead(micPin);
  server.send(200, "text/plain", String(soundVal));
}

void setup() {
  Serial.begin(115200);

  WiFi.softAP(ssid, password);
  Serial.println("Access Point Started");
  Serial.print("IP address: ");
  Serial.println(WiFi.softAPIP());  // usually 192.168.4.1

  server.on("/get-sound", handleData);
  server.begin();
}

void loop() {
  server.handleClient();
}

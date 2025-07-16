#include <WiFi.h>

// --- Wi-Fi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
// -------------------------

// Define the onboard LED pin (usually GPIO 2 on most DevKits)
#ifndef LED_BUILTIN
#define LED_BUILTIN 2
#endif

void setup() {
  // Start serial communication for debugging
  Serial.begin(115200);
  delay(100);

  // Set the LED pin as an output
  pinMode(LED_BUILTIN, OUTPUT);

  // Connect to Wi-Fi
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN)); // Blink LED while connecting
  }

  // Connection successful
  digitalWrite(LED_BUILTIN, HIGH); // Turn LED on solid to indicate connection
  Serial.println("\nWiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  // The main code can run here. For this test, we do nothing in the loop.
  // The solid LED indicates a persistent connection.
  delay(1000);
}
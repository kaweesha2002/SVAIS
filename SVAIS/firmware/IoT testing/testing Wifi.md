# ESP32 Wi-Fi Setup and IoT Data Retrieval Guide

This guide details the process of connecting the ESP32 to a Wi-Fi network, performing initial tests, and retrieving sensor data for the SVAIS project.

---

## 🎯 Objectives
1.  **Establish Wi-Fi Connectivity:** Connect the ESP32 to a local Wi-Fi network.
2.  **Perform a "Hello, World" Test:** Blink the onboard LED to confirm the device is running and connected.
3.  **Retrieve Sensor Data:** Read data from the MAX4466 microphone and expose it over the network.
4.  **Integrate into Main Project:** Outline the strategy for merging this IoT pipeline into the primary `main_detector.ino` sketch.

---

## 🛠️ Prerequisites
-   **Hardware:**
    -   ESP32 DevKit V1
    -   MAX4466 Microphone Module
    -   USB-A to Micro-USB cable
    -   Breadboard and jumper wires
-   **Software:**
    -   Arduino IDE installed.
    -   ESP32 Board support package installed in Arduino IDE. (If not, go to `File > Preferences` and add `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json` to "Additional Boards Manager URLs"). Then install "esp32" from `Tools > Board > Boards Manager`.

---

### Part 1: "Hello, World!" - Wi-Fi Connection & LED Blink

This initial test verifies that the ESP32 can connect to your Wi-Fi and that your development environment is correctly configured.

#### Arduino Sketch: `WiFi_Blink_Test.ino`
```cpp
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
```

#### Steps:
1.  Open the Arduino IDE.
2.  Copy and paste the code above into a new sketch.
3.  Replace `"YOUR_WIFI_SSID"` and `"YOUR_WIFI_PASSWORD"` with your network credentials.
4.  Go to `Tools > Board` and select your specific ESP32 DevKit model.
5.  Select the correct `Port` from the `Tools` menu.
6.  Click the "Upload" button.
7.  Once uploading is complete, open the **Serial Monitor** (`Tools > Serial Monitor`) and set the baud rate to `115200`.
8.  **Expected Outcome:** You will see connection status messages, followed by the ESP32's IP address. The onboard blue LED will blink while connecting and then stay on solid once connected.

---

### Part 2: Retrieving Sensor Data via a Web Server

Now, we'll create a simple web server on the ESP32. When you access it from a browser on the same network, it will return a reading from the microphone.

#### Hardware Setup:
-   Connect `VCC` of the MAX4466 to `3V3` on the ESP32.
-   Connect `GND` of the MAX4466 to `GND` on the ESP32.
-   Connect `OUT` of the MAX4466 to an ADC pin on the ESP32, for example, `GPIO 34`.

#### Arduino Sketch: `Sensor_WebServer.ino`
```cpp
#include <WiFi.h>
#include <WebServer.h>

// --- Wi-Fi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";
// -------------------------

// --- Hardware Pins ---
const int micPin = 34; // ADC1_CH6

// Create a WebServer object on port 80
WebServer server(80);

// Function to handle the root URL request
void handleRoot() {
  String html = "<h1>SVAIS ESP32 Server</h1>";
  html += "<p>Welcome to the Smart Voice-based Acoustic Intelligent System.</p>";
  html += "<p>Access <a href=\"/data\">/data</a> to get the current microphone reading.</p>";
  server.send(200, "text/html", html);
}

// Function to handle the data request
void handleGetData() {
  // Read a raw value from the microphone ADC
  int sensorValue = analogRead(micPin);
  
  // Send the value as a plain text response
  server.send(200, "text/plain", String(sensorValue));
}

void setup() {
  Serial.begin(115200);
  
  // Connect to Wi-Fi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Define server routes
  server.on("/", handleRoot);
  server.on("/data", handleGetData);

  // Start the server
  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  // Handle incoming client requests
  server.handleClient();
}
```

#### Steps:
1.  Wire the MAX4466 to the ESP32 as described.
2.  Use the code above, updating your Wi-Fi credentials.
3.  Upload the sketch to your ESP32.
4.  Open the Serial Monitor to get the device's IP address.
5.  Open a web browser on a computer or phone connected to the **same Wi-Fi network**.
6.  Navigate to `http://<YOUR_ESP32_IP>`. You should see the welcome page.
7.  Navigate to `http://<YOUR_ESP32_IP>/data`. The browser will display a raw integer value from the microphone. Refreshing the page will show a new value.

---

### Part 3: Integrating into the Main SVAIS Project

The final step is to merge this IoT capability with the event detection logic in `main_detector.ino`. The goal is **not** to stream raw audio, but to send a notification when a specific event (like a "clap") is detected.

#### Strategy:
1.  **Combine Code:** Add the `WiFi.h` and `WebServer.h` includes and the Wi-Fi connection logic from Part 2 into `main_detector.ino`.
2.  **Modify Detection Logic:** Instead of just printing "Clap Detected!" to the serial port, also set a global flag.
3.  **Create a Status Endpoint:** Create a web server endpoint (e.g., `/status`) that reports the last event.
4.  **Non-Blocking Code:** Ensure the main audio processing loop is not blocked by web server delays. The `server.handleClient()` call is non-blocking and fits well in the `loop()`.

#### Example Snippet for `main_detector.ino`:
```cpp
// ... (include WiFi.h, WebServer.h)
// ... (setup Wi-Fi credentials)
// ... (declare WebServer object)

// Global variable to store the last detected event
volatile String lastEvent = "none";
volatile unsigned long lastEventTime = 0;

// Web handler for checking the status
void handleStatus() {
  // Respond with the last event detected
  server.send(200, "text/plain", lastEvent);
  
  // Optional: Reset status after it has been read
  // lastEvent = "none"; 
}

void setup() {
  // ... (your existing setup code for serial, ADC, etc.)
  
  // ... (your Wi-Fi connection code)
  
  // Define and start the web server
  server.on("/status", handleStatus);
  server.begin();
}

void loop() {
  // ALWAYS handle client requests on each loop iteration
  server.handleClient();

  // ... (your existing audio sampling and feature extraction code)
  // ... (e.g., calculate RMS, ZCR, etc.)

  bool isClap = your_detection_logic(); // Your function that returns true on clap

  if (isClap) {
    Serial.println("Clap Detected!");
    lastEvent = "clap";
    lastEventTime = millis();
  }

  // Optional: Reset the event status after a timeout
  if (lastEvent != "none" && millis() - lastEventTime > 5000) {
    lastEvent = "none";
  }
  
  // ... (rest of your loop)
}
```
This approach allows the ESP32 to perform its primary function of real-time audio analysis while also serving IoT requests efficiently. A remote system can now poll the `/status` endpoint to know if a clap has occurred.
```// filepath: s:\Projects\EE254 Project\SVAIS\SVAIS\firmware\IoT testing\testing Wifi.md
# ESP32 Wi-Fi Setup and IoT Data Retrieval Guide

This guide details the process of connecting the ESP32 to a Wi-Fi network, performing initial tests, and retrieving sensor data for the SVAIS project.

---

## 🎯 Objectives
1.  **Establish Wi-Fi Connectivity:** Connect the ESP32 to a local Wi-Fi network.
2.  **Perform a "Hello, World" Test:** Blink the onboard LED to confirm the device is running and connected.
3.  **Retrieve Sensor Data:** Read data from the MAX4466 microphone and expose it over the network.
4.  **Integrate into Main Project:** Outline the strategy for merging this IoT pipeline into the primary `main_detector.ino` sketch.

---

## 🛠️ Prerequisites
-   **Hardware:**
    -   ESP32 DevKit V1
    -   MAX4466 Microphone Module
    -   USB-A to Micro-USB cable
    -   Breadboard and jumper wires
-   **Software:**
    -   Arduino IDE installed.
    -   ESP32 Board support package installed in Arduino IDE. (If not, go to `File > Preferences` and add `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json` to "Additional Boards Manager URLs"). Then install "esp32" from `Tools > Board > Boards Manager`.

---

### Part 1: "Hello, World!" - Wi-Fi Connection & LED Blink

This initial test verifies that the ESP32 can connect to your Wi-Fi and that your development environment is correctly configured.

#### Arduino Sketch: `WiFi_Blink_Test.ino`
```cpp

```

#### Steps:
1.  Open the Arduino IDE.
2.  Copy and paste the code above into a new sketch.
3.  Replace `"YOUR_WIFI_SSID"` and `"YOUR_WIFI_PASSWORD"` with your network credentials.
4.  Go to `Tools > Board` and select your specific ESP32 DevKit model.
5.  Select the correct `Port` from the `Tools` menu.
6.  Click
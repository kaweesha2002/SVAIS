// SVAIS main_detector.ino
// This Arduino sketch implements real-time sound event detection on the ESP32.

#include <Arduino.h>

const int micPin = 34; // Microphone input pin
const int threshold = 500; // Threshold for clap detection
const int ledPin = 2; // LED pin for visual feedback

void setup() {
    Serial.begin(115200); // Initialize serial communication
    pinMode(ledPin, OUTPUT); // Set LED pin as output
}

void loop() {
    int micValue = analogRead(micPin); // Read microphone value

    // Check if the microphone value exceeds the threshold
    if (micValue > threshold) {
        digitalWrite(ledPin, HIGH); // Turn on LED
        Serial.println("Clap detected!"); // Log detection
        delay(500); // Delay to avoid multiple detections
    } else {
        digitalWrite(ledPin, LOW); // Turn off LED
    }

    delay(10); // Small delay for stability
}
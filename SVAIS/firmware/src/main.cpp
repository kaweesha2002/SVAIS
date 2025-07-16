// main.cpp for the SVAIS project

#include <Arduino.h>

// Define pin mappings
const int micPin = 34; // Analog pin for MAX4466 microphone
const int speakerPin = 25; // DAC pin for PAM8403 speaker amplifier

void setup() {
    Serial.begin(115200); // Initialize serial communication
    pinMode(speakerPin, OUTPUT); // Set speaker pin as output
    // Additional setup code can be added here
}

void loop() {
    int micValue = analogRead(micPin); // Read microphone value
    Serial.println(micValue); // Print microphone value to serial monitor

    // Simple clap detection logic (placeholder)
    if (micValue > 1000) { // Threshold for clap detection
        tone(speakerPin, 1000, 500); // Play a tone on the speaker for 500ms
    }

    delay(100); // Delay for stability
}
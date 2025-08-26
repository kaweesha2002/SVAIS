// Simon Says LED Controller for ESP32
// Receives "SNAP", "CLAP", "KNOCK", "OFF", "WIN" via serial and controls LEDs

const int ledSnap = 12;   // GPIO pin for snap LED
const int ledClap = 25;   // GPIO pin for clap LED
const int ledKnock = 27;  // GPIO pin for knock LED

void setup() {
  pinMode(ledSnap, OUTPUT);
  pinMode(ledClap, OUTPUT);
  pinMode(ledKnock, OUTPUT);
  Serial.begin(115200);

  // Ensure all LEDs are OFF at start
  digitalWrite(ledSnap, LOW);
  digitalWrite(ledClap, LOW);
  digitalWrite(ledKnock, LOW);
}

void loop() {
  if (Serial.available()) {
    String cmd = Serial.readStringUntil('\n');
    cmd.trim();

    // All pins OFF before any ON (prevents ghosting/bleed)
    digitalWrite(ledSnap, LOW);
    digitalWrite(ledClap, LOW);
    digitalWrite(ledKnock, LOW);

    if (cmd == "SNAP") {
      digitalWrite(ledSnap, HIGH);
    } else if (cmd == "CLAP") {
      digitalWrite(ledClap, HIGH);
    } else if (cmd == "KNOCK") {
      digitalWrite(ledKnock, HIGH);
    } else if (cmd == "WIN") {
      // WIN pattern: cycle through each LED one at a time for 5 seconds
      unsigned long startTime = millis();
      unsigned long duration = 5000;    // 5 seconds
      unsigned long ledPeriod = 500;    // 0.5 seconds per LED
      int ledOrder[3] = {ledSnap, ledClap, ledKnock};
      int idx = 0;
      while (millis() - startTime < duration) {
        // Turn current LED ON, others OFF
        for (int i = 0; i < 3; i++) {
          digitalWrite(ledOrder[i], (i == idx) ? HIGH : LOW);
        }
        delay(ledPeriod);
        idx = (idx + 1) % 3;
        // Check for serial to break early if needed
        if (Serial.available()) break;
      }
      // After WIN, turn all LEDs OFF
      digitalWrite(ledSnap, LOW);
      digitalWrite(ledClap, LOW);
      digitalWrite(ledKnock, LOW);
    } else if (cmd == "OFF") {
      // Already OFF above, do nothing
    }
    // else ignore unknown
  }
}
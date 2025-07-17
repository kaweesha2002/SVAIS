#include <Arduino.h>
#include <WiFi.h>

#define MIC_PIN 35
#define SAMPLES 128         // Number of audio samples per frame
#define SAMPLE_RATE 5000    // Hz

const char* ssid = "Dialog 4G 602";
const char* password = "DE8625cD";

WiFiServer server(80);

int16_t audioBuffer[SAMPLES];
unsigned long lastSampleTime = 0;

// Band definitions (Hz) for energy analysis
const int NUM_BANDS = 4;
const int bandLimits[NUM_BANDS+1] = {0, 800, 1600, 2400, 2500}; // 0-800, 800-1600, 1600-2400, 2400-2500 Hz

bool lastSnapDetected = false;
int lastAmplitude = 0;
int lastZCR = 0;
float lastRatios[NUM_BANDS] = {0};

void setup() {
  Serial.begin(115200);

  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  server.begin();
}

void loop() {
  // 1. Collect audio samples
  for (int i = 0; i < SAMPLES; i++) {
    while (micros() - lastSampleTime < 1000000 / SAMPLE_RATE) {}
    lastSampleTime = micros();
    audioBuffer[i] = analogRead(MIC_PIN);
  }

  // 2. Amplitude Feature (Peak)
  int minVal = 4096, maxVal = 0;
  for (int i = 0; i < SAMPLES; i++) {
    if (audioBuffer[i] < minVal) minVal = audioBuffer[i];
    if (audioBuffer[i] > maxVal) maxVal = audioBuffer[i];
  }
  int amplitude = maxVal - minVal;

  // 3. Zero Crossing Rate (ZCR)
  int zcr = 0;
  int mid = (maxVal + minVal) / 2; // DC offset compensation
  for (int i = 1; i < SAMPLES; i++) {
    if (((audioBuffer[i-1] - mid) > 0) != ((audioBuffer[i] - mid) > 0)) zcr++;
  }

  // 4. Energy Ratios in Bands (approximate)
  float bandEnergy[NUM_BANDS] = {0};
  for (int b = 0; b < NUM_BANDS; b++) {
    for (int i = 0; i < SAMPLES; i++) {
      float freq = (i * SAMPLE_RATE) / SAMPLES;
      if (freq >= bandLimits[b] && freq < bandLimits[b+1]) {
        bandEnergy[b] += sq(audioBuffer[i] - mid);
      }
    }
    bandEnergy[b] /= SAMPLES / NUM_BANDS;
  }
  float totalEnergy = 1e-6;
  for (int b = 0; b < NUM_BANDS; b++) totalEnergy += bandEnergy[b];
  float ratio[NUM_BANDS];
  for (int b = 0; b < NUM_BANDS; b++) ratio[b] = bandEnergy[b] / totalEnergy;

  // 5. Snap Detection Logic
  bool amplitudeOK = amplitude > 1000;
  bool zcrOK = zcr > 10 && zcr < 30;
  bool bandOK = ratio[2] > 0.35 && ratio[2] < 0.7;

  bool snapDetected = amplitudeOK && zcrOK; // (or include bandOK if you want)

  if (snapDetected) {
    Serial.print("Snap detected!   ");
    Serial.print("Amp: "); Serial.print(amplitude);
    Serial.print("  ZCR: "); Serial.print(zcr);
    Serial.print("  Bands: ");
    for (int b = 0; b < NUM_BANDS; b++) {
      Serial.print(ratio[b], 2); Serial.print(" ");
    }
    Serial.println();
    delay(200); // avoid rapid repeat
  }

  // Store for web display
  lastSnapDetected = snapDetected;
  lastAmplitude = amplitude;
  lastZCR = zcr;
  for (int b = 0; b < NUM_BANDS; b++) lastRatios[b] = ratio[b];

  // Serve web client
  WiFiClient client = server.available();
  if (client) {
    // Simple HTTP response
    client.println("HTTP/1.1 200 OK");
    client.println("Content-Type: text/html");
    client.println();
    client.println("<html><head><title>Snap Detection</title></head><body>");
    client.println("<h1>Snap Detection Status</h1>");
    client.print("<p>Snap Detected: <b>");
    client.print(lastSnapDetected ? "YES" : "NO");
    client.println("</b></p>");
    client.print("<p>Amplitude: "); client.print(lastAmplitude); client.println("</p>");
    client.print("<p>ZCR: "); client.print(lastZCR); client.println("</p>");
    client.print("<p>Band Ratios: ");
    for (int b = 0; b < NUM_BANDS; b++) {
      client.print(lastRatios[b], 2); client.print(" ");
    }
    client.println("</p>");
    client.println("<meta http-equiv='refresh' content='1'>");
    client.println("</body></html>");
    client.stop();
  }

  delay(10);
}
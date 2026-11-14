/*
  =========================================================
                  ALERTXBAND - V1.0
              ESP32 INTEGRATED FIRMWARE
  =========================================================

  INPUTS:
    MPU6050 - Motion / Fall detection
    NEO-6M  - GPS
    DHT22   - Temperature / Humidity
    MQ-2    - Gas sensor

  OUTPUTS:
    Buzzer
    Red / Yellow / Green LEDs
    GPS LED
    16x2 I2C LCD

  CLOUD:
    Firebase Realtime Database REST API
  =========================================================
*/


/*
  UPDATED BUILD NOTES:
  - Fill in WIFI_PASS, FIREBASE_API_KEY, FIREBASE_DEVICE_EMAIL,
    and FIREBASE_DEVICE_PASSWORD before uploading.
  - Firebase authentication diagnostics print HTTP status and error bodies.\n  - JSON token extraction tolerates whitespace and escaped characters.\n  - Sign-in diagnostics report token-field presence without exposing tokens.
  - Successful authentication response bodies are intentionally NOT printed,
    because they contain ID and refresh tokens.
  - setInsecure() is retained for initial testing only. Validate TLS certificates
    before deploying this device in real-world safety use.
*/

#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <TinyGPSPlus.h>
#include <DHT.h>
#include <LiquidCrystal_I2C.h>
#include <math.h>
#include "config.h"  // Local-only secrets; see config.example.h

// =========================================================
// 1. CONFIGURATION
// =========================================================

const char* WIFI_SSID = AXB_WIFI_SSID;
const char* WIFI_PASS = AXB_WIFI_PASSWORD;

// Firebase Realtime Database ROOT URL.
// Do not add /devices/... here.
const char* SERVER_URL = AXB_FIREBASE_DATABASE_URL;

const char* DEVICE_ID = AXB_DEVICE_ID;

// Firebase Email/Password account dedicated to this ESP32.
// Replace placeholders locally. Never publish real credentials.
const char* FIREBASE_API_KEY = AXB_FIREBASE_API_KEY;
const char* FIREBASE_DEVICE_EMAIL = AXB_FIREBASE_DEVICE_EMAIL;
const char* FIREBASE_DEVICE_PASSWORD = AXB_FIREBASE_DEVICE_PASSWORD;

String firebaseIdToken = "";
String firebaseRefreshToken = "";
unsigned long firebaseTokenExpiry = 0;
bool firebaseAuthenticated = false;

// =========================================================
// 2. PIN CONFIGURATION
// =========================================================

#define DHT_PIN       4
#define DHT_TYPE      DHT22

#define GPS_RX_PIN    16
#define GPS_TX_PIN    17

#define GAS_PIN       34

#define BUZZER_PIN    18

#define RED_LED       25
#define YELLOW_LED    26
#define GREEN_LED     27
#define GPS_LED       13

#define SDA_PIN       21
#define SCL_PIN       22

// Set true if your traffic-light module is common anode.
const bool LED_ACTIVE_LOW = false;

// =========================================================
// 3. THRESHOLDS - CALIBRATE AFTER TESTING
// =========================================================

// Your MQ-2 test showed approximately 255 in the
// current test environment. This is only a starting
// threshold, not a calibrated gas concentration.
const int GAS_LIMIT = 600;

const float TEMP_HIGH = 38.0;
const float TEMP_LOW  = 10.0;

// Exact fall-detection thresholds from the previously working sketch.
const float FREEFALL_THRESHOLD = 0.65; // g
const float IMPACT_THRESHOLD   = 2.50; // g
const unsigned long FALL_WINDOW = 1500;
const unsigned long ALERT_DURATION = 5000;

const unsigned long NORMAL_UPLOAD_MS = 5000;
const unsigned long ALERT_UPLOAD_MS  = 1500;

// =========================================================
// 4. SENSOR OBJECTS
// =========================================================

DHT dht(DHT_PIN, DHT_TYPE);

TinyGPSPlus gps;
HardwareSerial gpsSerial(2);

const uint8_t MPU_ADDR = 0x68;

LiquidCrystal_I2C* lcd = nullptr;

bool lcdAvailable = false;
bool mpuAvailable = false;

// =========================================================
// 5. SENSOR VARIABLES
// =========================================================

float temperature = 0.0;
float humidity = 0.0;

int gasValue = 0;

float accX = 0;
float accY = 0;
float accZ = 0;

float gyroX = 0;
float gyroY = 0;
float gyroZ = 0;

float accMag = 1.0;
float gyroMag = 0.0;

bool dhtValid = false;

bool fallDetected = false;
bool freeFallDetected = false;
bool gasAlert = false;
bool tempAlert = false;

bool lastUploadOk = false;

unsigned long freeFallTime = 0;
unsigned long alertStartTime = 0;

// =========================================================
// 6. TIMERS
// =========================================================

unsigned long lastSensorRead = 0;
unsigned long lastLCDUpdate = 0;
unsigned long lastUpload = 0;
unsigned long lastBlink = 0;
unsigned long lastBeep = 0;

bool blinkState = false;
bool beepState = false;
bool lcdPage = false;

// =========================================================
// 7. LED CONTROL
// =========================================================

void setLED(int pin, bool state) {

  if (LED_ACTIVE_LOW) {
    digitalWrite(pin, state ? LOW : HIGH);
  } else {
    digitalWrite(pin, state ? HIGH : LOW);
  }
}

// =========================================================
// 8. MPU6050 RAW REGISTER FUNCTIONS
// =========================================================

bool readBytes(uint8_t reg, uint8_t count, uint8_t* data) {

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(reg);

  if (Wire.endTransmission(false) != 0) {
    return false;
  }

  if (Wire.requestFrom(MPU_ADDR, count) != count) {
    return false;
  }

  for (uint8_t i = 0; i < count; i++) {
    data[i] = Wire.read();
  }

  return true;
}

int16_t toInt16(uint8_t highByte, uint8_t lowByte) {
  return (int16_t)((highByte << 8) | lowByte);
}

void writeReg(uint8_t reg, uint8_t value) {

  Wire.beginTransmission(MPU_ADDR);
  Wire.write(reg);
  Wire.write(value);
  Wire.endTransmission();
}

// =========================================================
// 9. MPU6050 INITIALIZATION
// =========================================================

void mpuInit() {

  Serial.println("\nInitializing MPU6050...");

  uint8_t identity;

  if (!readBytes(0x75, 1, &identity)) {
    Serial.println("MPU6050 communication failed!");
    mpuAvailable = false;
    return;
  }

  Serial.print("WHO_AM_I: 0x");
  Serial.println(identity, HEX);

  // Your previously tested module returned 0x74.
  if (identity != 0x74 && identity != 0x68) {
    Serial.println("Unexpected IMU identity!");
    mpuAvailable = false;
    return;
  }

  // Preserve the configuration from your working test.
  writeReg(0x6B, 0x01);
  delay(100);

  writeReg(0x1C, 0x00); // Accelerometer +/-2g
  writeReg(0x1B, 0x00); // Gyroscope +/-250 deg/s
  writeReg(0x1A, 0x03); // DLPF
  writeReg(0x19, 0x07); // Sample rate

  mpuAvailable = true;

  Serial.println("IMU initialization successful!");
}

// =========================================================
// 10. MPU6050 DATA READING
// =========================================================

void readMPU() {

  if (!mpuAvailable) return;

  uint8_t data[14];

  if (!readBytes(0x3B, 14, data)) {
    Serial.println("IMU data read failed!");
    return;
  }

  int16_t ax = toInt16(data[0], data[1]);
  int16_t ay = toInt16(data[2], data[3]);
  int16_t az = toInt16(data[4], data[5]);

  // Skip temperature registers.
  int16_t gx = toInt16(data[8], data[9]);
  int16_t gy = toInt16(data[10], data[11]);
  int16_t gz = toInt16(data[12], data[13]);

  accX = ax / 16384.0;
  accY = ay / 16384.0;
  accZ = az / 16384.0;

  gyroX = gx / 131.0;
  gyroY = gy / 131.0;
  gyroZ = gz / 131.0;

  accMag = sqrt(
    accX * accX +
    accY * accY +
    accZ * accZ
  );

  gyroMag = sqrt(
    gyroX * gyroX +
    gyroY * gyroY +
    gyroZ * gyroZ
  );

}

// =========================================================
// 10A. FALL DETECTION - RESTORED FROM THE PREVIOUSLY
//      WORKING ALERTXBAND SKETCH
// =========================================================

void detectFall() {

  if (!mpuAvailable) return;

  unsigned long now = millis();

  // Stage 1: detect free-fall.
  if (accMag < FREEFALL_THRESHOLD) {
    freeFallDetected = true;
    freeFallTime = now;
  }

  // Stage 2: detect impact within the fall window.
  if (freeFallDetected) {

    if (now - freeFallTime <= FALL_WINDOW) {

      if (accMag > IMPACT_THRESHOLD) {
        fallDetected = true;
        alertStartTime = now;
        freeFallDetected = false;

        Serial.println("POSSIBLE FALL DETECTED!");
      }

    } else {
      freeFallDetected = false;
    }
  }

  // Keep the fall alert active for the original 5 seconds.
  if (fallDetected &&
      now - alertStartTime >= ALERT_DURATION) {
    fallDetected = false;
  }
}

// =========================================================
// 11. GPS INITIALIZATION
// =========================================================

void gpsInit() {

  gpsSerial.begin(
    9600,
    SERIAL_8N1,
    GPS_RX_PIN,
    GPS_TX_PIN
  );

  Serial.println("NEO-6M GPS initialized!");
}

// =========================================================
// 12. LCD INITIALIZATION
// =========================================================

void lcdInit() {

  Serial.println("\nScanning for LCD...");

  uint8_t foundAddress = 0;

  // Detect standard PCF8574 / PCF8574A addresses.
  for (uint8_t address = 0x20; address <= 0x27; address++) {

    Wire.beginTransmission(address);

    if (Wire.endTransmission() == 0) {
      foundAddress = address;
      break;
    }
  }

  if (foundAddress == 0) {

    for (uint8_t address = 0x38; address <= 0x3F; address++) {

      Wire.beginTransmission(address);

      if (Wire.endTransmission() == 0) {
        foundAddress = address;
        break;
      }
    }
  }

  if (foundAddress == 0) {
    Serial.println("LCD backpack not detected!");
    Serial.println("Continuing without LCD.");
    return;
  }

  Serial.print("LCD I2C address: 0x");
  Serial.println(foundAddress, HEX);

  lcd = new LiquidCrystal_I2C(foundAddress, 16, 2);

  lcd->init();
  lcd->backlight();
  lcd->clear();

  lcd->setCursor(0, 0);
  lcd->print("ALERTXBAND");

  lcd->setCursor(0, 1);
  lcd->print("Initializing...");

  lcdAvailable = true;

  Serial.println("LCD initialization attempted.");
}

// =========================================================
// 13. DHT22 + MQ-2 READING
// =========================================================

void readEnvironment() {

  float t = dht.readTemperature();
  float h = dht.readHumidity();

  dhtValid = !isnan(t) && !isnan(h);

  if (dhtValid) {
    temperature = t;
    humidity = h;
  } else {
    Serial.println("DHT22 reading failed!");
  }

  gasValue = analogRead(GAS_PIN);

  gasAlert = gasValue > GAS_LIMIT;

  tempAlert =
    (dhtValid &&
     (temperature > TEMP_HIGH ||
      temperature < TEMP_LOW));
}

// =========================================================
// 14. ALERT STATUS
// =========================================================

bool isAbnormal() {
  return fallDetected || gasAlert || tempAlert;
}

String getStatus() {

  if (fallDetected) return "FALL";
  if (gasAlert) return "GAS";
  if (tempAlert) return "TEMP";

  return "NORMAL";
}

// =========================================================
// 15. FIREBASE JSON PAYLOAD
// =========================================================

String buildPayload() {

  bool gpsValid =
    gps.location.isValid() &&
    gps.location.age() < 5000;

  String json = "{";

  json += "\"deviceId\":\"" + String(DEVICE_ID) + "\",";
  json += "\"status\":\"" + getStatus() + "\",";

  json += "\"alert\":";
  json += isAbnormal() ? "true," : "false,";

  json += "\"fall\":";
  json += fallDetected ? "true," : "false,";

  json += "\"gasAlert\":";
  json += gasAlert ? "true," : "false,";

  json += "\"tempAlert\":";
  json += tempAlert ? "true," : "false,";

  json += "\"temperature\":";
  json += dhtValid ? String(temperature, 1) : "null";
  json += ",";

  json += "\"humidity\":";
  json += dhtValid ? String(humidity, 1) : "null";
  json += ",";

  json += "\"dhtValid\":";
  json += dhtValid ? "true," : "false,";

  json += "\"gas\":";
  json += String(gasValue) + ",";

  json += "\"acceleration\":";
  json += String(accMag, 3) + ",";

  json += "\"gyro\":";
  json += String(gyroMag, 2) + ",";

  json += "\"imuValid\":";
  json += mpuAvailable ? "true," : "false,";

  json += "\"gpsValid\":";
  json += gpsValid ? "true," : "false,";

  json += "\"latitude\":";
  json += gpsValid ? String(gps.location.lat(), 6) : "null";
  json += ",";

  json += "\"longitude\":";
  json += gpsValid ? String(gps.location.lng(), 6) : "null";
  json += ",";

  json += "\"satellites\":";
  json += String(gps.satellites.value()) + ",";

  json += "\"hdop\":";
  json += gps.hdop.isValid()
    ? String(gps.hdop.hdop(), 2)
    : "null";
  json += ",";

  json += "\"altitude\":";
  json += gps.altitude.isValid()
    ? String(gps.altitude.meters(), 2)
    : "null";
  json += ",";

  json += "\"speedKmph\":";
  json += gps.speed.isValid()
    ? String(gps.speed.kmph(), 2)
    : "null";
  json += ",";

  json += "\"uptimeMs\":";
  json += String(millis());

  json += "}";

  return json;
}

// =========================================================
// 16. FIREBASE EMAIL/PASSWORD AUTHENTICATION
// =========================================================

String jsonEscape(const String& input) {
  String escaped;
  escaped.reserve(input.length() + 8);
  for (size_t i = 0; i < input.length(); i++) {
    char c = input[i];
    if (c == '"' || c == '\\') {
      escaped += '\\';
      escaped += c;
    } else if (c == '\n') {
      escaped += "\\n";
    } else if (c == '\r') {
      escaped += "\\r";
    } else if (c == '\t') {
      escaped += "\\t";
    } else {
      escaped += c;
    }
  }
  return escaped;
}

// Extract a JSON string value, allowing whitespace after the colon
// and handling common escaped characters.
String jsonStringField(const String& json, const char* field) {
  String key = String("\"") + field + "\"";

  int keyPosition = json.indexOf(key);
  if (keyPosition < 0) return "";

  int colonPosition = json.indexOf(':', keyPosition + key.length());
  if (colonPosition < 0) return "";

  int start = colonPosition + 1;

  while (start < (int)json.length() &&
         (json[start] == ' ' || json[start] == '\t' ||
          json[start] == '\n' || json[start] == '\r')) {
    start++;
  }

  if (start >= (int)json.length() || json[start] != '"') return "";

  start++;
  String value;
  value.reserve(64);

  for (int i = start; i < (int)json.length(); i++) {
    char c = json[i];

    if (c == '"') return value;

    if (c == '\\' && i + 1 < (int)json.length()) {
      i++;
      char escaped = json[i];

      switch (escaped) {
        case '"':  value += '"'; break;
        case '\\': value += '\\'; break;
        case '/':  value += '/'; break;
        case 'n':  value += '\n'; break;
        case 'r':  value += '\r'; break;
        case 't':  value += '\t'; break;
        case 'b':  value += '\b'; break;
        case 'f':  value += '\f'; break;
        default:   value += escaped; break;
      }
    } else {
      value += c;
    }
  }

  return "";
}

bool postFirebaseAuthRequest(
  const String& url,
  const String& body,
  const char* contentType,
  String& response
) {
  WiFiClientSecure client;
  client.setInsecure(); // TESTING ONLY. Use certificate validation in production.
  HTTPClient http;

  response = "";

  Serial.println();
  Serial.println("========== FIREBASE AUTH DEBUG ==========");
  Serial.print("WiFi status: ");
  Serial.println(WiFi.status());
  Serial.println("Preparing HTTPS request...");

  http.setConnectTimeout(15000);
  http.setTimeout(15000);

  if (!http.begin(client, url)) {
    Serial.println("ERROR: HTTP initialization failed.");
    Serial.println("========== END AUTH DEBUG ==============");
    return false;
  }

  Serial.println("HTTPS initialization: SUCCESS");
  http.addHeader("Content-Type", contentType);

  Serial.println("Sending Firebase POST request...");
  int code = http.POST(body);

  Serial.print("Firebase Auth HTTP response: ");
  Serial.println(code);

  if (code > 0) {
    response = http.getString();

    Serial.print("Firebase response length: ");
    Serial.println(response.length());

    if (code >= 200 && code < 300) {
      // Do NOT print successful response bodies: they contain ID and refresh tokens.
      Serial.println("Firebase authentication endpoint accepted the request.");
    } else {
      // Error responses are useful for diagnosing invalid credentials/API settings.
      Serial.println("Firebase error response:");
      Serial.println(response);
    }
  } else {
    Serial.print("HTTPS transport error: ");
    Serial.println(http.errorToString(code));
    Serial.println("No HTTP response was received from Firebase.");
  }

  http.end();
  Serial.println("========== END AUTH DEBUG ==============");

  return (code >= 200 && code < 300);
}

bool firebaseSignIn() {
  if (WiFi.status() != WL_CONNECTED) return false;

  if (String(FIREBASE_API_KEY).startsWith("YOUR_") ||
      String(FIREBASE_DEVICE_EMAIL).startsWith("YOUR_") ||
      String(FIREBASE_DEVICE_PASSWORD).startsWith("YOUR_") ||
      strlen(FIREBASE_API_KEY) == 0 ||
      strlen(FIREBASE_DEVICE_EMAIL) == 0 ||
      strlen(FIREBASE_DEVICE_PASSWORD) == 0) {
    Serial.println("Firebase Auth: Fill in API key, device email and password.");
    firebaseAuthenticated = false;
    return false;
  }

  String url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=";
  url += FIREBASE_API_KEY;

  String body = "{";
  body += "\"email\":\"" + jsonEscape(String(FIREBASE_DEVICE_EMAIL)) + "\",";
  body += "\"password\":\"" + jsonEscape(String(FIREBASE_DEVICE_PASSWORD)) + "\",";
  body += "\"returnSecureToken\":true}";

  String response;
  Serial.println("Signing in to Firebase...");
  if (!postFirebaseAuthRequest(url, body, "application/json", response)) {
    firebaseAuthenticated = false;
    return false;
  }

  String idToken = jsonStringField(response, "idToken");
  String refreshToken = jsonStringField(response, "refreshToken");
  String expiresIn = jsonStringField(response, "expiresIn");

  // Report field presence only. Never print token values.
  Serial.println("Firebase JSON parsing diagnostics:");
  Serial.print("Response starts with JSON object: ");
  Serial.println(response.indexOf('{') >= 0 ? "YES" : "NO");

  Serial.print("idToken field found: ");
  Serial.println(idToken.length() > 0 ? "YES" : "NO");

  Serial.print("refreshToken field found: ");
  Serial.println(refreshToken.length() > 0 ? "YES" : "NO");

  Serial.print("expiresIn field found: ");
  Serial.println(expiresIn.length() > 0 ? "YES" : "NO");

  if (idToken.length() == 0 || refreshToken.length() == 0) {
    Serial.println("Firebase Auth: Required token fields missing.");
    Serial.println("Check Firebase response format and HTTP diagnostics.");
    firebaseAuthenticated = false;
    return false;
  }

  unsigned long lifetime = expiresIn.length() > 0
                           ? expiresIn.toInt()
                           : 3600UL;

  if (lifetime == 0) lifetime = 3600UL;

  firebaseIdToken = idToken;
  firebaseRefreshToken = refreshToken;
  firebaseTokenExpiry =
    millis() + (lifetime > 300 ? lifetime - 300 : lifetime) * 1000UL;

  firebaseAuthenticated = true;
  Serial.println("Firebase Email/Password sign-in SUCCESS.");
  return true;
}

bool firebaseRefreshIdToken() {
  if (WiFi.status() != WL_CONNECTED || firebaseRefreshToken.length() == 0) {
    return false;
  }

  String url = "https://securetoken.googleapis.com/v1/token?key=";
  url += FIREBASE_API_KEY;
  String body = "grant_type=refresh_token&refresh_token=" + firebaseRefreshToken;

  String response;
  if (!postFirebaseAuthRequest(
        url, body, "application/x-www-form-urlencoded", response)) {
    return false;
  }

  String idToken = jsonStringField(response, "id_token");
  String refreshToken = jsonStringField(response, "refresh_token");
  String expiresIn = jsonStringField(response, "expires_in");
  if (idToken.length() == 0) return false;

  unsigned long lifetime = expiresIn.length() ? expiresIn.toInt() : 3600UL;
  firebaseIdToken = idToken;
  if (refreshToken.length()) firebaseRefreshToken = refreshToken;
  firebaseTokenExpiry = millis() + (lifetime > 300 ? lifetime - 300 : lifetime) * 1000UL;
  firebaseAuthenticated = true;
  Serial.println("Firebase ID token refreshed.");
  return true;
}

bool ensureFirebaseAuthentication() {
  if (WiFi.status() != WL_CONNECTED) {
    firebaseAuthenticated = false;
    return false;
  }

  if (firebaseIdToken.length() &&
      (long)(firebaseTokenExpiry - millis()) > 0) {
    firebaseAuthenticated = true;
    return true;
  }

  if (firebaseRefreshToken.length() && firebaseRefreshIdToken()) {
    return true;
  }

  Serial.println("Refreshing failed/unavailable; signing in again.");
  firebaseIdToken = "";
  firebaseAuthenticated = false;
  return firebaseSignIn();
}

// =========================================================
// 17. FIREBASE UPLOAD
// =========================================================

void uploadToFirebase() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Upload skipped.");
    lastUploadOk = false;
    firebaseAuthenticated = false;
    return;
  }

  if (!ensureFirebaseAuthentication()) {
    Serial.println("Firebase authentication unavailable. Upload skipped.");
    lastUploadOk = false;
    return;
  }

  String endpoint = String(SERVER_URL) + "/devices/" +
                    String(DEVICE_ID) + ".json?auth=" + firebaseIdToken;
  String payload = buildPayload();

  Serial.println("\nUploading authenticated data to Firebase...");
  Serial.println(payload);

  WiFiClientSecure client;
  client.setInsecure(); // Testing only; use certificate validation in production.
  HTTPClient http;

  if (!http.begin(client, endpoint)) {
    Serial.println("Firebase HTTP initialization failed!");
    lastUploadOk = false;
    return;
  }

  http.setTimeout(10000);
  http.addHeader("Content-Type", "application/json");
  int httpCode = http.PUT(payload);
  String response = http.getString();
  http.end();

  Serial.print("Firebase HTTP response: ");
  Serial.println(httpCode);

  // Re-authenticate once if the token was rejected, then retry the PUT.
  if (httpCode == 401 || httpCode == 403) {
    Serial.println("Firebase rejected token. Signing in again...");
    firebaseIdToken = "";
    firebaseTokenExpiry = 0;
    firebaseAuthenticated = false;

    if (firebaseSignIn()) {
      String retryEndpoint = String(SERVER_URL) + "/devices/" +
                             String(DEVICE_ID) + ".json?auth=" + firebaseIdToken;
      WiFiClientSecure retryClient;
      retryClient.setInsecure(); // Testing only.
      HTTPClient retryHttp;

      if (retryHttp.begin(retryClient, retryEndpoint)) {
        retryHttp.setTimeout(10000);
        retryHttp.addHeader("Content-Type", "application/json");
        httpCode = retryHttp.PUT(payload);
        response = retryHttp.getString();
        retryHttp.end();
      } else {
        httpCode = -1;
      }
    } else {
      httpCode = -1;
    }
  }

  if (httpCode >= 200 && httpCode < 300) {
    Serial.println("FIREBASE UPDATE SUCCESS!");
    lastUploadOk = true;
  } else {
    Serial.println("FIREBASE UPDATE FAILED!");
    if (response.length()) Serial.println(response);
    lastUploadOk = false;
  }
}

// =========================================================
// 18. LED INDICATORS
// =========================================================

void updateLEDs() {

  setLED(GREEN_LED, false);
  setLED(YELLOW_LED, false);
  setLED(RED_LED, false);

  if (fallDetected) {
    setLED(RED_LED, blinkState);
  }
  else if (gasAlert || tempAlert) {
    setLED(YELLOW_LED, blinkState);
  }
  else {
    setLED(GREEN_LED, true);
  }

  bool gpsValid =
    gps.location.isValid() &&
    gps.location.age() < 5000;

  setLED(GPS_LED, gpsValid);
}

// =========================================================
// 19. BUZZER
// =========================================================

void updateBuzzer() {

  // Match the previously working sketch: buzzer sounds for fall alerts.
  if (fallDetected) {
    ledcWriteTone(BUZZER_PIN, 2000);
  } else {
    ledcWriteTone(BUZZER_PIN, 0);
  }
}

// =========================================================
// 20. LCD DISPLAY
// =========================================================

void updateLCD() {

  if (!lcdAvailable || lcd == nullptr) return;

  bool gpsValid =
    gps.location.isValid() &&
    gps.location.age() < 5000;

  lcd->clear();

  if (isAbnormal()) {

    lcd->setCursor(0, 0);
    lcd->print("ALERT: ");
    lcd->print(getStatus());

    lcd->setCursor(0, 1);

    if (fallDetected) {
      lcd->print("FALL DETECTED!");
    }
    else if (gasAlert) {
      lcd->print("GAS LEVEL HIGH!");
    }
    else if (temperature > TEMP_HIGH) {
      lcd->print("TEMP TOO HIGH!");
    }
    else {
      lcd->print("TEMP TOO LOW!");
    }

    return;
  }

  // Alternate between two information pages.
  if (!lcdPage) {

    lcd->setCursor(0, 0);
    lcd->print("T:");
    lcd->print(temperature, 1);
    lcd->print("C H:");
    lcd->print((int)humidity);
    lcd->print("%");

    lcd->setCursor(0, 1);
    lcd->print("G:");
    lcd->print(gasValue);
    lcd->print(" ");

    if (WiFi.status() == WL_CONNECTED) {
      lcd->print(lastUploadOk ? "CLOUD OK" : "NET WAIT");
    } else {
      lcd->print("NO WIFI");
    }

  } else {

    if (gpsValid) {

      lcd->setCursor(0, 0);
      lcd->print("Lat:");
      lcd->print(gps.location.lat(), 5);

      lcd->setCursor(0, 1);
      lcd->print("Lon:");
      lcd->print(gps.location.lng(), 5);

    } else {

      lcd->setCursor(0, 0);
      lcd->print("GPS: NO FIX");

      lcd->setCursor(0, 1);
      lcd->print("Sats:");
      lcd->print(gps.satellites.value());
    }
  }
}

// =========================================================
// 21. SERIAL MONITOR DIAGNOSTICS
// =========================================================

void printDiagnostics() {

  Serial.println("\n================================");
  Serial.println("       ALERTXBAND STATUS");
  Serial.println("================================");

  Serial.print("Device ID: ");
  Serial.println(DEVICE_ID);

  Serial.print("Temperature: ");
  if (dhtValid) Serial.print(temperature);
  else Serial.print("INVALID");
  Serial.println(" C");

  Serial.print("Humidity: ");
  if (dhtValid) Serial.print(humidity);
  else Serial.print("INVALID");
  Serial.println(" %");

  Serial.print("Gas ADC: ");
  Serial.println(gasValue);

  Serial.print("Acceleration: ");
  Serial.print(accMag);
  Serial.println(" g");

  Serial.print("Gyroscope: ");
  Serial.print(gyroMag);
  Serial.println(" deg/s");

  Serial.print("Fall: ");
  Serial.println(fallDetected ? "YES" : "NO");

  Serial.print("Gas Alert: ");
  Serial.println(gasAlert ? "YES" : "NO");

  Serial.print("Temperature Alert: ");
  Serial.println(tempAlert ? "YES" : "NO");

  Serial.print("GPS Valid: ");
  Serial.println(
    gps.location.isValid() &&
    gps.location.age() < 5000 ? "YES" : "NO"
  );

  Serial.print("Satellites: ");
  Serial.println(gps.satellites.value());

  if (gps.location.isValid() &&
      gps.location.age() < 5000) {

    Serial.print("Latitude: ");
    Serial.println(gps.location.lat(), 6);

    Serial.print("Longitude: ");
    Serial.println(gps.location.lng(), 6);

    Serial.print("Google Maps: https://www.google.com/maps?q=");
    Serial.print(gps.location.lat(), 6);
    Serial.print(",");
    Serial.println(gps.location.lng(), 6);
  }

  Serial.print("WiFi: ");
  Serial.println(
    WiFi.status() == WL_CONNECTED ? "CONNECTED" : "DISCONNECTED"
  );

  Serial.print("Firebase Auth: ");
  Serial.println(firebaseAuthenticated ? "AUTHENTICATED" : "NOT AUTHENTICATED");

  Serial.print("Firebase: ");
  Serial.println(lastUploadOk ? "SUCCESS" : "NOT CONFIRMED");

  Serial.println("================================");
}

// =========================================================
// 22. SETUP
// =========================================================

void setup() {

  Serial.begin(115200);
  delay(1000);

  Serial.println("\n\n");
  Serial.println("================================");
  Serial.println("   ALERTXBAND INITIALIZATION");
  Serial.println("================================");

  // Initialize I2C.
  Wire.begin(SDA_PIN, SCL_PIN);
  Wire.setClock(100000);

  // Initialize sensors.
  dht.begin();
  Serial.println("DHT22 initialized!");

  gpsInit();
  mpuInit();

  analogReadResolution(12);
  analogSetPinAttenuation(GAS_PIN, ADC_11db);

  Serial.println("MQ-2 initialized!");

  // Initialize outputs.
  // Passive buzzer: use the same ESP32 LEDC tone setup as the
  // previously working sketch.
  ledcAttach(BUZZER_PIN, 2000, 8);
  ledcWriteTone(BUZZER_PIN, 0);

  pinMode(RED_LED, OUTPUT);
  pinMode(YELLOW_LED, OUTPUT);
  pinMode(GREEN_LED, OUTPUT);
  pinMode(GPS_LED, OUTPUT);

  ledcWriteTone(BUZZER_PIN, 0);

  setLED(RED_LED, false);
  setLED(YELLOW_LED, false);
  setLED(GREEN_LED, false);
  setLED(GPS_LED, false);

  // Initialize LCD.
  lcdInit();

  // Connect WiFi.
  Serial.println("\nConnecting to WiFi...");

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASS);

  unsigned long wifiStart = millis();

  while (WiFi.status() != WL_CONNECTED &&
         millis() - wifiStart < 15000) {

    delay(500);
    Serial.print(".");
  }

  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {

    Serial.println("WiFi connected!");

    Serial.print("IP Address: ");
    Serial.println(WiFi.localIP());

  } else {

    Serial.println("WiFi connection failed!");
    Serial.println("Device will continue local monitoring.");
  }

  if (lcdAvailable) {

    lcd->clear();
    lcd->setCursor(0, 0);
    lcd->print("ALERTXBAND READY");

    lcd->setCursor(0, 1);
    lcd->print("Monitoring...");

  }

  Serial.println("\nINITIALIZATION COMPLETE!");
  Serial.println("Starting live monitoring...");
}

// =========================================================
// 23. MAIN LOOP
// =========================================================

void loop() {

  unsigned long now = millis();

  // -----------------------------------------
  // GPS: continuously process incoming data.
  // -----------------------------------------

  while (gpsSerial.available() > 0) {
    gps.encode(gpsSerial.read());
  }

  // -----------------------------------------
  // MPU6050: read motion data.
  // -----------------------------------------

  readMPU();
  detectFall();

  // -----------------------------------------
  // DHT22 + MQ-2: read every 2 seconds.
  // -----------------------------------------

  if (now - lastSensorRead >= 2000) {

    lastSensorRead = now;

    readEnvironment();

    printDiagnostics();
  }

  // -----------------------------------------
  // LED blinking.
  // -----------------------------------------

  if (now - lastBlink >= 300) {

    lastBlink = now;
    blinkState = !blinkState;
  }

  updateLEDs();

  // -----------------------------------------
  // Buzzer alert.
  // -----------------------------------------

  updateBuzzer();

  // -----------------------------------------
  // LCD update.
  // -----------------------------------------

  if (now - lastLCDUpdate >= 1000) {

    lastLCDUpdate = now;

    lcdPage = !lcdPage;

    updateLCD();
  }

  // -----------------------------------------
  // Firebase upload.
  // -----------------------------------------

  unsigned long uploadInterval =
    isAbnormal() ? ALERT_UPLOAD_MS : NORMAL_UPLOAD_MS;

  if (now - lastUpload >= uploadInterval) {

    lastUpload = now;

    uploadToFirebase();
  }

  delay(5);
}

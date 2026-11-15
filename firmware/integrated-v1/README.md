# AlertXBand V1.0 Integrated ESP32 Firmware

This directory contains the integrated V1.0 firmware sketch for the AlertXBand ESP32 prototype.

## Files

- `AlertXBand_V1.0.ino` — complete integrated firmware.
- `../../config.example.h` — template for local Wi-Fi and Firebase configuration.

## Hardware covered by this firmware

- ESP32 development board
- MPU6050 — motion sensing and free-fall/impact event detection
- NEO-6M — GPS parsing
- DHT22 — temperature and humidity
- MQ-2 — gas sensor ADC reading
- Buzzer, red/yellow/green status LEDs, GPS LED
- 16x2 I2C LCD

The sketch also connects to Wi-Fi and sends device data to Firebase Realtime Database using the REST API and Firebase Email/Password authentication.

## Setup

1. Install the ESP32 board package in Arduino IDE.
2. Install these Arduino libraries:
   - TinyGPSPlus
   - DHT sensor library
   - LiquidCrystal_I2C
3. Copy `firmware/config.example.h` to this directory and rename the copy to `config.h`.
4. Edit the local `config.h` with your Wi-Fi and Firebase values.
5. Open `AlertXBand_V1.0.ino` in Arduino IDE, select the correct ESP32 board and port, then compile and upload.

**Never commit `config.h` or share its credentials.** The repository ignore rules exclude files named `config.h` under `firmware/`.

## Before testing

- Confirm the wiring and GPIO assignments in the sketch match your physical prototype.
- Confirm the Firebase Realtime Database URL and device account are correct.
- Check Serial Monitor output during startup, GPS acquisition, sensor reads, authentication, and database uploads.
- Test each sensor independently before relying on the integrated system.

## Known limitations and validation required

- The sketch uses `WiFiClientSecure::setInsecure()` for initial testing. Replace this with proper certificate validation before deployment.
- `GAS_LIMIT` is an uncalibrated ADC threshold, not a measured gas concentration. Calibrate it for the sensor, environment, and required use case.
- Fall-detection thresholds and timing require controlled testing with representative movements and false-positive/false-negative analysis.
- Verify Firebase Security Rules restrict access to authorized users and the intended device.
- This prototype is not a certified medical device and cannot guarantee emergency delivery.

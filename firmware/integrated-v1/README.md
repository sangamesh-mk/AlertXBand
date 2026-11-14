# AlertXBand V1.0 Integrated ESP32 Firmware

The integrated sketch supplied for V1.0 has been reviewed and prepared with credentials separated into a local-only `config.h`.

## Firmware package

The sanitized sketch package is available in the current ChatGPT conversation as `AlertXBand_V1.0_Firmware_Package.zip`. Add its `AlertXBand_V1.0.ino` file to this directory when uploading the package to the repository.

## Configuration

1. Copy `config.example.h` to `config.h` beside the sketch.
2. Fill in Wi-Fi and Firebase values in the local `config.h`.
3. Do not commit `config.h`; the repository `.gitignore` excludes it.
4. Change the Firebase device-account password that was present in the original uploaded sketch.

## Libraries

Install TinyGPSPlus, DHT sensor library, and LiquidCrystal_I2C. Wi-Fi, WiFiClientSecure, HTTPClient, Wire, and HardwareSerial are provided by the ESP32 Arduino core.

## Implemented in the supplied V1.0 sketch

- MPU6050 raw-register acquisition and free-fall/impact event logic.
- NEO-6M GPS parsing.
- DHT22 and MQ-2 acquisition.
- Buzzer, status LEDs, GPS LED, and 16x2 I2C LCD.
- Wi-Fi connectivity, Firebase Email/Password sign-in/token refresh, and Realtime Database REST upload.

## Validation and safety notes

- The source uses `WiFiClientSecure::setInsecure()` for initial testing; certificate validation is required before real-world deployment.
- MQ-2 threshold is an uncalibrated ADC threshold, not a gas concentration.
- Fall detection requires validation against representative movements and false-positive cases.
- Firebase database rules must restrict access to the intended device/user.
- This prototype is not a certified medical device and cannot guarantee emergency delivery.

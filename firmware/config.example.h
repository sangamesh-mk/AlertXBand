#pragma once

// AlertXBand firmware configuration template.
// Copy to a local config.h and fill in verified values.
// Never commit real credentials.

#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
#define DEVICE_ID "AXB-DEVICE-001"

// ESP32 I2C pins used in the MPU6050 bench-test setup.
// Verify against final assembled wiring.
#define I2C_SDA_PIN 21
#define I2C_SCL_PIN 22

// GPS baud rate used during development tests.
// Confirm UART pins from the actual wiring.
#define GPS_BAUD_RATE 9600
#define GPS_RX_PIN -1
#define GPS_TX_PIN -1

// Set these only after verifying the physical pin map.
#define DHT_DATA_PIN -1
#define MQ2_ADC_PIN -1
#define BUZZER_PIN -1
#define STATUS_LED_PIN -1

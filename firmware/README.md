# AlertXBand Firmware

This folder is for embedded software running on the wearable controller, currently developed around ESP32.

## Suggested layout

```text
firmware/
├── README.md
├── config.example.h
├── src/
│   ├── main.cpp
│   ├── sensors/
│   ├── motion/
│   ├── gps/
│   ├── gsm/
│   ├── connectivity/
│   └── alerts/
├── examples/
│   ├── mpu6050_test/
│   ├── gps_test/
│   ├── max30102_test/
│   ├── dht22_test/
│   ├── mq2_test/
│   ├── display_test/
│   └── sim800l_test/
└── docs/
    ├── firmware-architecture.md
    └── build-and-flash.md
```

This is a recommended organization, not a claim that these source files already exist. Add the actual tested sketches; do not replace working firmware with placeholders.

## Firmware responsibilities

1. Initialize the controller and peripherals.
2. Acquire sensor samples with validity checks and timestamps.
3. Process motion data using documented, tested event logic.
4. Acquire and validate GPS coordinates.
5. Manage Wi-Fi and/or GSM communication.
6. Transmit telemetry and event state to the configured backend.
7. Drive local buzzer/LED indications.
8. Handle sensor faults, network loss, and recovery.

## Record for every release

Board model/FQBN, ESP32 core version, library versions, GPIO mapping, build/upload steps, serial baud rate, firmware version, and test date.

Never commit Wi-Fi passwords, API keys, access tokens, personal contact details, or private service-account credentials. Keep local secrets in an ignored local config file.

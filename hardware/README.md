# AlertXBand Hardware

This folder documents the wearable prototype, electronic components, wiring, power design, and hardware validation.

## Contents

- `components-list.md` — bill of materials and component purpose.
- `circuit-connections.md` — GPIO and wiring map.
- `power-management.md` — battery, charging, protection, and regulation.
- `hardware-testing.md` — test procedures and observed results.
- `circuit-diagrams/` — wiring diagrams and schematics.
- `prototype-images/` — photographs of the actual prototype.

## Known development details

The project has used an ESP32 with MPU6050/IMU, NEO-6M GPS, MAX30102-compatible pulse sensor, MQ-2, DHT22, display modules, buzzer/LED indicators, and a SIM800L GSM module during development. Confirm which modules are present in the final build before treating this as the final bill of materials.

The MPU6050 bench-test setup used ESP32 I2C SDA GPIO 21 and SCL GPIO 22, with the sensor detected at address 0x68. GPS tests used 9600 baud. Verify all pins against the actual assembled prototype.

## Safety and accuracy

- Never power a SIM800L directly from the ESP32 3V3 output; use a suitable supply designed for its current bursts.
- Verify voltage levels before connecting module outputs to ESP32 pins.
- Check battery polarity, charger wiring, protection board, and regulator output before powering the device.
- Record measured results; do not infer a successful test from an indicator LED alone.
- The prototype is not a certified medical device or guaranteed emergency response system.

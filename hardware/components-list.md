# AlertXBand Bill of Materials

Initial component inventory based on the project development record. Confirm exact module variants and quantities against the physical prototype.

| Component | Intended purpose | Verification required |
|---|---|---|
| ESP32 development board | Main microcontroller | Exact board variant |
| MPU6050 / IMU | Accelerometer and gyroscope for motion analysis | Module identity, I2C address |
| NEO-6M GPS | Location acquisition | Antenna and valid outdoor fix |
| SIM800L | GSM calls and SMS | Network compatibility and stable supply |
| MAX30102 / compatible pulse sensor | Optical pulse and SpO2 estimation | Exact sensor variant and signal quality |
| MQ-2 | Gas/smoke sensing | Warm-up, calibration, analog scaling |
| DHT22 | Ambient temperature and humidity | Sensor version and data wiring |
| SSD1306 OLED | Local status display | Resolution and I2C address |
| 16x2 I2C LCD | Local text display | Backpack address and voltage |
| Buzzer and LEDs | Audible/visual indication | Active/passive buzzer and ratings |
| 18650 Li-ion cell | Portable power | Cell rating and protection |
| TP4056 module | Single-cell charging | Board variant and charge-current setting |
| 1S protection board | Cell protection | Board ratings and wiring |
| Regulators/converters | Required regulated supply rails | Output voltage under load |
| Wires/connectors/prototype board | Interconnection | Current and voltage ratings |

This inventory does not mean every item is installed or working simultaneously. Update quantities and verification status after inspecting the final build.

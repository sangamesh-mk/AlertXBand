# AlertXBand Circuit Connections

## Verified development notes

| Module | Interface | Development note | Status |
|---|---|---|---|
| MPU6050 / IMU | I2C | ESP32 SDA GPIO 21, SCL GPIO 22; address observed as 0x68 | Bench-tested previously |
| NEO-6M GPS | UART | 9600 baud used in tests | Confirm RX/TX GPIOs |
| MAX30102 | I2C | I2C interface | Confirm address and wiring |
| SSD1306 OLED | I2C | I2C interface | Confirm address and wiring |
| 16x2 I2C LCD | I2C | I2C backpack | Confirm address and bus voltage |
| SIM800L | UART + dedicated power | Requires supply capable of GSM current bursts | Confirm wiring and supply |
| MQ-2 | Analog output | ESP32 ADC input with safe voltage scaling | Confirm module output |
| DHT22 | Digital | Digital data interface | Confirm GPIO and pull-up |
| Buzzer / LEDs | Digital output | Use appropriate driver/resistor | Confirm GPIO and component type |

## Final pin map — complete from the assembled device

| ESP32 pin | Module pin | Signal | Voltage | Status |
|---|---|---|---|---|
| To be confirmed | To be confirmed | To be confirmed | To be confirmed | Pending |

## Electrical checks

- Do not power SIM800L from the ESP32 3V3 pin.
- Use a suitable regulated supply for SIM800L according to the exact module specification.
- Do not expose ESP32 inputs to 5 V signals.
- Ensure common ground where required for separately powered modules.
- Check I2C addresses for conflicts when sharing the bus.
- Confirm all wiring with a meter before applying power.

Do not treat unconfirmed GPIO assignments as wiring instructions.

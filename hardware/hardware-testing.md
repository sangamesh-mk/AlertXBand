# AlertXBand Hardware Testing

Record repeatable tests of the physical device.

## Test log

| Date | Module | Setup | Expected result | Observed result | Status |
|---|---|---|---|---|---|
| YYYY-MM-DD | Example: MPU6050 | ESP32 I2C scan and serial output | Device detected; readings respond to movement | Add measured output | Pass/Fail/Blocked |

## Test checklist

- [ ] ESP32 boots reliably over USB.
- [ ] Battery power path and regulated rails measured under load.
- [ ] MPU6050 identity and motion readings verified.
- [ ] GPS obtains a valid fix outdoors; coordinates checked.
- [ ] MAX30102 signal quality and repeatability assessed.
- [ ] DHT22 readings compared with a reference instrument.
- [ ] MQ-2 warm-up and response procedure documented.
- [ ] OLED and LCD tested.
- [ ] Buzzer and LEDs tested.
- [ ] SIM800L network registration, SMS, and calls tested with stable power.
- [ ] Full-system operation tested with modules active together.

A module LED lighting up is not sufficient evidence of a successful functional test. Include serial logs, measurements, test conditions, and limitations.
